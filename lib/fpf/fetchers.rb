require_relative 'fetcher'
require_relative 'logger'
require 'set'
require 'redis'

module FullPageFetcher

  class Fetchers

    include FullPageFetcher::Logger

    def initialize(start, size, options = nil)
      @port_start = start
      @port_size = size
      @options = options || {}
      @max_wait = @options.fetch(:max_wait, 10)
      @wait_time = @options.fetch(:wait_time, 1)
      @redis = @options.fetch(:redis) { Redis.new }
      setup!
    end

    def next
      begin
        port = checkout
        yield new_fetcher(port)
      ensure
        checkin(port)
      end
    end

    private

    def checkout
      port = redis.rpop(queue_key)
      port || wait_for_availability
    end

    def wait_for_availability
      wait do
        port = redis.rpop(queue_key)
        break port unless port.nil?
      end
    end

    def wait
      @waited = 0
      loop do
        sleep @wait_time
        @waited += @wait_time
        yield
        break if @waited > @max_wait
      end
    end

    def queue_key
      "fpf:#{Process.ppid}"
    end

    def checkin(port)
      redis.lpush queue_key, port
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

