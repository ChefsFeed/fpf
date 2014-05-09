$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'bundler'
Bundler.require

require 'rack/deflater'
require 'fpf'

require 'sidekiq/web'
map '/workers' do
  run Sidekiq::Web
end

use Rack::Deflater
run FullPageFetcher::App
