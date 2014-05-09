$LOAD_PATH.unshift File.join(Dir.pwd, 'lib')
require 'bundler'
Bundler.require

desc "Open console"
task :console do
  require 'pry'
  require 'fpf'
  ARGV.clear
  Pry.start
end