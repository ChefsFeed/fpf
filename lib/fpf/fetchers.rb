require_relative 'fetcher'
require_relative 'logger'
require 'set'
require 'redis'

module FullPageFetcher

  class NoFetcherAvailableException < Exception; end

  class Fetchers

    MAX_LIFETIME_REQUESTS = ENV.fetch('FPF_MAX_LIFETIME_REQUESTS', '10').to_i

    include FullPageFetcher::Logger

    def initialize(start, size, options = nil)
      @port_start = start
      @port_size = size
      @options = options || {}
      @max_wait = @options.fetch(:max_wait, 10)
      @redis = @options.fetch(:redis) { Redis.new }
      setup!
    end

    def next
      begin
        port = checkout
        raise NoFetcherAvailableException.new unless port
        yield new_fetcher(port)
      ensure
        checkin(port) if port
      end
    end

    def current_concurrency
      @port_size - redis.llen(queue_key)
    end

    def max_concurrency
      @port_size
    end

    private

    def checkout
      response = redis.brpop(queue_key, @max_wait)
      if response
        port = response.last
        current_usage = redis.hget(quota_key, port).to_i
        logger.info "Current Usage for #{port}: #{current_usage}"
        if current_usage > MAX_LIFETIME_REQUESTS
          reset(port)
        end
        redis.hincrby(quota_key, port, 1)
        port
      end
    end

    def queue_key
      "fpf:#{Process.ppid}"
    end

    def quota_key
      "fpf:#{Process.ppid}:requests_counter"
    end

    def checkin(port)
      redis.lpush queue_key, port
    end

    def reset(port)
      l.debug "killing FPF for #{port} and waiting..."
      pid = `lsof -i TCP:#{port} -t`.to_i
      logger.info "Killing pid: #{pid.inspect}"
      Process.kill(:TERM, pid)

      sleep 1
      until system("nc -z localhost #{port}")
        l.debug "waiting for FPF for #{port} to come back up..."
        sleep 1
      end
    end

    def setup!
      if redis.exists(queue_key)
        l.warn "Existing key: #{queue_key}. Already running on #{Process.ppid} "
      else
        (@port_start...(@port_start+@port_size)).each do |port|
          checkin(port)
        end
      end
    end

    def new_fetcher(port)
      Fetcher.new("http://localhost:#{port}")
    end

    def redis
      @redis
    end

  end
end

