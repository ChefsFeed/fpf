require_relative 'fetchers'

module FullPageFetcher
  module Config

    extend self

    def fetchers_port_start
      @fetchers_port_start ||= ENV.fetch('FPF_PHANTOM_PORT_START', 8910).to_i
    end

    def fetchers_port_count
      @fetchers_port_count ||= ENV.fetch('FPF_PHANTOM_PORT_COUNT', 10).to_i
    end

    def fetchers
      @fetchers ||= FullPageFetcher::Fetchers.new(fetchers_port_start, fetchers_port_count)
    end

    def fetchers_ports
      (fetchers_port_start...(fetchers_port_start + fetchers_port_count))
    end

  end
end
