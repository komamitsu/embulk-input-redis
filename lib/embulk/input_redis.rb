module Embulk

  class InputRedis < InputPlugin
    require 'redis'
    require 'json'

    Plugin.register_input('redis', self)

    def self.transaction(config, &control)
      task = {
        'host' => config.param('host', :string, :default => 'localhost'),
        'port' => config.param('port', :int, :default => 6379),
        'db' => config.param('db', :int, :default => 0),
        'key_prefix' => config.param('key_prefix', :string, :default => ''),
        'encode' => config.param('encode', :string, :default => 'json'),
        'columns' => config.param('columns', :hash, :default => nil),
      }
      threads = config.param('threads', :int, default: 1)

      columns =
        if cs = task['columns']
          xs = []
          cs.each_with_index do |c, i|
            xs << Column.new(i, c[0], c[1])
          end
          xs
        else
          [
            Column.new(0, 'key', :string),
            Column.new(1, 'value', :string),
          ]
        end

      puts "Redis input started."
      commit_reports = yield(task, columns, threads)
      puts "Redis input finished. Commit reports = #{commit_reports.to_json}"

      return {}
    end

    def self.run(task, schema, index, page_builder)
      puts "Redis input thread #{index}..."

      r = ::Redis.new(:host => task['host'], :port => task['port'], :db => task['db'])
      r.keys("#{task['key_prefix']}*").each do |k|
        # TODO: Use MGET or something
        v = r.get(k)
        case task['encode']
        when 'json'
          if task['columns']
            hash = JSON.parse(v)
            xs = [k] + hash.values
            page_builder.add([k, xs])
          else
            page_builder.add([k, v])
          end
        end
      end
      page_builder.finish  # don't forget to call finish :-)

      commit_report = {
      }
      return commit_report
    end
  end

end
