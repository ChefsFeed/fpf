require './lib/fpf'

module FullPageFetcher
  class RequestPage

    include Sidekiq::Worker
    sidekiq_options queue: "default", dead: false, retry: 5
    
    def perform(path)
      sleep(1)
      FullPage.save(path, "<<<<< CONTENT FOR: #{path} ")
    end

  end
end
