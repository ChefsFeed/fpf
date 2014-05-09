$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'bundler'
Bundler.require

require 'rack/deflater'
require 'fpf/app'

use Rack::Deflater
run FullPageFetcher::App