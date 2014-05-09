require './lib/fpf'

module FullPageFetcher
  class FetchesPage

    def initialize(path)
      @page = FullPage.find(req.fullpath)
    end

  end
end
