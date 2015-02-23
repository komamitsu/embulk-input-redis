module Embulk

  class InputRedis < InputPlugin
    require 'redis'
    require 'json'

    Plugin.register_input('redis', self)

    def self.guess
    end

    def self.transaction(config, &control)
      task = {
        'host' => config.param('host', :string, :default => 'localhost'),
        'port' => config.param('port', :integer, :default => 6379),
        'db' => config.param('db', :integer, :default => 0),
        'key_prefix' => config.param('key_prefix', :string, :default => ''),
        'encode' => config.param('encode', :string, :default => 'json'),
        'columns' =>
          config.param('columns', :array, :default => []).inject({}){|a, col|
            a[col['name']] = col['type'].to_sym
            a
          },
        'rows' => 0
      }

      columns = task['columns'].map.with_index{|(name, type), i|
        Column.new(i, name, type)
      }

      puts "Redis input started."
      commit_reports = yield(task, columns, 1)
      puts "Redis input finished. Commit reports = #{commit_reports.to_json}"

      return {}
    end

    def deserialize_element(x)
      @task['columns'].map{|(name, type)|
        begin
          val = x[name]
          case type.to_sym  # Converted to String implicitly?
          when :boolean
            if val.is_a?(TrueClass) || val.is_a?(FalseClass)
              val
            else
              downcased_val = val.downcase
              case downcased_val
              when 'true' then true
              when 'false' then false
              else nil
              end
            end
          when :long
            Integer(val)
          when :double
            Float(val)
          when :string
            val
          when :timestamp
            Time.parse(val)
          else
            raise "Shouldn't reach here: val:#{val}, col_name:#{name}, col_type:#{type}"
          end
        rescue => e
          STDERR.puts "Failed to deserialize: val:#{val}, col_name:#{name}, col_type:#{type}, error:#{e.inspect}"
        end
      }
    end

    def run
      puts "Redis input thread #{@index}..."
      r = Redis.new(:host => @task['host'], :port => @task['port'], :db => @task['db'])
      r.keys("#{@task['key_prefix']}*").each do |k|
        case @task['encode']
        when 'json'
          v = r.get(k)
          x = JSON.parse(v)
          @page_builder.add(deserialize_element(x))
        when 'hash'
          x = r.hgetall(k)
          @page_builder.add(deserialize_element(x))
        end
        @task['rows'] += 1
      end
      @page_builder.finish  # don't forget to call finish :-)

      commit_report = {
        "rows" => @task['rows']
      }
      return commit_report
    end
  end

end
