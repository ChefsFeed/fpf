require 'cuba'
require 'cuba/prelude'
require 'cuba/render'
require 'cuba/text_helpers'
require 'fpf/fetcher'
require 'fpf/request_page'
require 'rack/protection'
require 'rack/reloader'
require 'securerandom'

module FullPageFetcher
  class App < Cuba

    use Rack::Session::Cookie, secret: SecureRandom.hex(64)
    use Rack::Protection
    use Rack::Reloader

    plugin Cuba::Render
    plugin Cuba::Prelude
    plugin Cuba::TextHelpers

    settings[:render][:views] = File.join(Dir.pwd, 'lib', 'fpf', 'views')

    define do
      on get do
        fetcher = Fetcher.new(req.fullpath)
        if (page = fetcher.fetch)
          res.write page.content
        else
          res.status = 404
          res.write "Can't find #{req.fullpath}!"
        end
      end
    end
  end

end
