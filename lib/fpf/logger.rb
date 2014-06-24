require 'logger'

module FullPageFetcher
  module Logger

    def logger
      @logger ||= ::Logger.new(STDOUT).tap do |logger|
        STDOUT.sync = true
        logger.formatter = proc do |sev, date, prog, msg|
          thread_id = sprintf '%x', Thread.current.object_id
          formatted_date = date.strftime "%Y-%m-%d %H:%M:%S"
          [ formatted_date, sev, thread_id, msg ].join(' ') + "\n"
        end
      end
    end

    def l
      logger
    end

  end
end
