$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'bundler'
Bundler.require

require 'fpf'
require 'fpf/cache'
require 'rack/deflater'

use Rack::Deflater
use FullPageFetcher::Cache
run FullPageFetcher::App
