module Embulk

  class InputRedis < InputPlugin
    require 'redis'

    Plugin.register_input('redis', self)

    def self.transaction(config, &control)
      task = {
        'host' => config.param('host', :string, :default => 'localhost'),
        'port' => config.param('port', :int, :default => 6379),
        'db' => config.param('db', :int, :default => 0),
        'key_prefix' => config.param('key_prefix', :string, :default => ''),
      }
      threads = config.param('threads', :int, default: 1)

      columns = [
        Column.new(0, 'key', :string),
        Column.new(1, 'value', :string),
      ]

      puts "Redis input started."
      commit_reports = yield(task, columns, threads)
      puts "Redis input finished. Commit reports = #{commit_reports.to_json}"

      return {}
    end

    def run
      puts "Redis input thread #{@index}..."

      r = ::Redis.new(:host => @task['host'], :port => @task['port'], :db => @task['db'])
      r.keys("#{@task['key_prefix']}*").each do |k|
        @page_builder.add([k, r.get(k)])
      end
      @page_builder.finish  # don't forget to call finish :-)

      commit_report = {
      }
      return commit_report
    end
  end

end
