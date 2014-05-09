require 'cuba'
require 'cuba/prelude'
require 'cuba/render'
require 'cuba/text_helpers'
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

    settings[:render][:template_engine] = "slim"
    settings[:render][:views] = File.join(Dir.pwd, 'lib', 'fpf', 'views')

    define do 
      on do 
        res.write "Good to go. "
      end
    end
  end
end
