require 'fpf'

module FullPageFetcher
  class Fetcher

    attr_reader :path

    def initialize(path)
      @path = path
      @max_retries = 10
    end

    def fetch
      page = FullPage.find(path)
      return page unless page.nil?
      request
      wait_for_page
    end

    def request
      l.info "Requesting Page: #{path}"
      RequestPage.perform_async(path)
    end

    def wait_for_page
      wait do
        page = FullPage.find(path)
        break page unless page.nil?
      end
    end

    private

    def wait(&block)
      @retries = 0
      loop do
        sleep(1)
        yield
        @retries += 1
        break if @max_retries < @retries
      end
    end

    def self.l
      @@logger ||=
        Logger.new(STDOUT).tap do |logger|
          logger.formatter = proc do |sev, date, prog, msg|
            thread_id = sprintf '%x', Thread.current.object_id
            formatted_date = date.strftime "%Y-%m-%d %H:%M:%S"
            [ formatted_date, sev, thread_id, msg ].join(' ')
          end
        end
    end

    def l
      self.class.l
    end
  end

end
