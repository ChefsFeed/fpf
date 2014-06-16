require_relative 'config'
require 'fileutils'

module FullPageFetcher
  class Cache

    def initialize(app)
      @app = app
      FileUtils.mkdir_p(base_path) unless File.exists?(base_path)
    end

    def call(env)
      if env['REQUEST_METHOD']== 'GET'
        path = cleanup_path(env['REQUEST_PATH'])

        if content = fetch(path)
          [200, {}, [content]]
        else
          body = @app.call(env).last
          store(path, body)
          [201, {}, body]
        end
      else
        @app.call(env)
      end
    end

    def store(path, body)
      full_path = cache_path_for(path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.open(full_path, "w") {|f| f.write(body.first)}
    end

    def fetch(path)
      full_path = cache_path_for(path)
      File.read(full_path) if File.exists?(full_path)
    end

    def base_path
      Config.cache_path
    end

    def cache_path_for(path)
      cache_path = File.join(base_path, path)
      cache_path.gsub!(/\/$/, '')
      cache_path += '.html'
      File.absolute_path(cache_path)
    end

    def cleanup_path(path)
      path
    end

  end
end
