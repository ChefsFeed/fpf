require_relative 'config'
require_relative 'logger'
require 'fileutils'

module FullPageFetcher
  class Cache

    include FullPageFetcher::Logger

    def initialize(app)
      @app = app
      FileUtils.mkdir_p(base_path) unless File.exists?(base_path)
    end

    def call(env)
      if env['REQUEST_METHOD']== 'GET'
        path = cleanup_path(env['REQUEST_PATH'])

        content, cache_path = fetch(path)
        if content
          l.debug "CACHE HIT; serving #{path} from #{cache_path}"
          [200, {}, [content]]
        else
          status, headers, body, was_successful = send_upstream(env)
          store(path, body) if was_successful

          [ status, headers, body ]
        end
      else
        @app.call(env)
      end
    end

    def send_upstream(env)
      status, headers, body = @app.call(env)
      was_successful = status.to_s[0] == '2'
      [ status, headers, body, was_successful ]
    end

    def store(path, body)
      full_path = cache_path_for(path)
      l.debug "storing #{path} into #{full_path}"
      FileUtils.mkdir_p(File.dirname(full_path))
      File.open(full_path, "w") {|f| f.write(body.first)}
    end

    def fetch(path)
      full_path = cache_path_for(path)
      [ File.read(full_path), full_path ] if File.exists?(full_path)
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
