require 'logger'
require 'digest'

module FullPageFetcher
  module Logger

    def thread_id
      @thread_id ||= Digest::MD5.hexdigest(Thread.current.object_id.to_s)[0..6]
    end

    def logger
      @logger ||= ::Logger.new(STDOUT).tap do |logger|
        STDOUT.sync = true
        logger.formatter = proc do |sev, date, prog, msg|
          sprintf "%-5s %s - %s\n", sev, thread_id, msg
        end
      end
    end

    def l
      logger
    end

  end
end
