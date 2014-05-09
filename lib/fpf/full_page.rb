require 'fpf'

module FullPageFetcher
  class FullPage

    def self.root_path
      File.join(Dir.pwd, "tmp")
    end

    def self.save(path, content)
      File.open(full_path(path), "w") do |f|
        f.write(content)
      end
      load_page(path, content)
    end

    def self.find(path)
      load_page(path) if exists?(path)
    end

    def self.exists?(path)
      File.exists?(full_path(path))
    end

    attr_reader :content, :path

    def initialize(path, content)
      @path = path
      @content = content
    end

    def valid?
      true
    end

    private

    def self.full_path(path)
      File.join(root_path, path)
    end

    def self.load_page(path, content = nil)
      content ||= File.open(full_path(path)).read
      new(path, content)
    end
  end
end
