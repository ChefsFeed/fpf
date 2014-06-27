require 'cuba'
require 'fpf/config'
require 'fpf/logger'
require 'rack/protection'
require 'securerandom'

module FullPageFetcher
  class App < Cuba

    include FullPageFetcher::Logger

    use Rack::Session::Cookie, secret: SecureRandom.hex(64)
    use Rack::Protection

    def fetch_content(path)
      Config.fetchers.next do |fetcher|
        concurrency = sprintf "%02d/%02d",
          Config.fetchers.current_concurrency,
          Config.fetchers.max_concurrency
        l.info "START #{req.fullpath} - #{concurrency}"

        fetcher.fetch(path)
      end
    end

    define do
      on get do
        start_time = Time.now
        begin
          if content = fetch_content(req.fullpath)
            res.write content
          else
            l.warn "NOT FOUND: #{req.fullpath}"
            res.status = 404
            res.write "Not found"
          end
        rescue FullPageFetcher::NoFetcherAvailableException
          l.error "TIMEOUT; no fetchers available - #{req.fullpath}"
          res.status = 503
        ensure
          l.info sprintf "END #{req.fullpath} - %dms", (Time.now - start_time) * 1000
        end
      end
    end
  end
end

