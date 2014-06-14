require 'cuba'
require 'fpf/fetchers'
require 'fpf/fetcher'
require 'fpf/logger'
require 'rack/protection'
require 'rack/reloader'
require 'securerandom'

module FullPageFetcher
  class App < Cuba

    include FullPageFetcher::Logger

    use Rack::Session::Cookie, secret: SecureRandom.hex(64)
    use Rack::Protection

    def fetch_content(path)
      FETCHERS.next do |fetcher|
        fetcher.fetch(path)
      end
    end

    define do
      on get do
        l.info "Requested: #{req.fullpath}"
        if content = fetch_content(req.fullpath)
          l.info "Found #{req.fullpath}"
          res.write content
        else
          l.error "NOT Found #{req.fullpath}"
          res.status = 404
          res.write "Can't find #{req.fullpath}!"
        end
      end
    end
  end
end

