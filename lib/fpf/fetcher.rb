require 'fpf'
require 'fpf/logger'
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
      logger.info @driver.send :bridge
    end

    def fetch(path)
      uri = URI.parse(base_url + path)
      l.info "[WD:#{@port}] Requested path: #{uri}"
      @driver.get uri

      wait_for(10) do |n|
        begin
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
      @base_url ||= 'http://localhost:5002'
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
