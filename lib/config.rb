require 'redis'
require 'fpf/fetchers'
port_start = ENV.fetch('FPF_PHANTOM_PORT_START', 8910).to_i
port_count = ENV.fetch('FPF_PHANTOM_PORT_COUNT', 10).to_i

FETCHERS = FullPageFetcher::Fetchers.new(port_start, port_count)
