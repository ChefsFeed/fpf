# encoding: utf-8
require_relative 'logger'
require 'selenium-webdriver'
require 'uri'

module FullPageFetcher

  class Fetcher

    include FullPageFetcher::Logger

    def initialize(url, options = nil)
      @url = url
      @port = URI.parse(url).port
      @options ||= {}
      @base_url = @options[:base_url]
      @driver = Selenium::WebDriver.for(:remote, url: @url)
    end

    def fetch(path)
      uri = URI.parse(base_url + path)
      @driver.get uri

      wait_for(10) do |n|
        begin
          #FIXME: take this from an env var, or don't wait if no value was given there
          #FIXME: consider using CSS here for easier config
          element = @driver.find_element(xpath: '//*/meta[starts-with(@property, \'og:image\')]')
          content = element.attribute('content')
          if content && content != ''
            content
          end
        rescue Selenium::WebDriver::Error::NoSuchElementError => e
          nil
        end
      end

      @driver.page_source
    end

    def base_url
      @base_url ||= ENV['FPF_UPSTREAM_BASE_URL'] || 'http://localhost:5002'
    end

    def wait_for(max_times, &block)
      @times = 0
      loop do
        sleep(1)
        @times += 1
        thing = block.call(@times)
        return thing unless thing.nil?
        break thing if @times >= max_times
      end
    end
  end

end
