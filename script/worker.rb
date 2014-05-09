$:.unshift File.join(Dir.pwd, 'lib')
require 'bundler'
Bundler.require
require 'fpf'
