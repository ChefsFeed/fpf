$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'bundler'
Bundler.require

require 'fpf/fetcher_app'

run FullPageFetcher::FetcherApp
