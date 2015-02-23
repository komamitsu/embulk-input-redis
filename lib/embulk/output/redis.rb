module Embulk

  class OutputRedis < OutputPlugin
    require 'redis'
    require 'json'
    require 'set'

    Plugin.register_output('redis', self)

    def self.transaction(config, schema, processor_count, &control)
      task = {
        'host' => config.param('host', :string, :default => 'localhost'),
        'port' => config.param('port', :integer, :default => 6379),
        'db' => config.param('db', :integer, :default => 0),
        'key' => config.param('key', :string),
        'key_prefix' => config.param('key_prefix', :string, :default => ''),
        'encode' => config.param('encode', :string, :default => 'json'),
      }

      puts "Redis output started."
      commit_reports = yield(task)
      puts "Redis output finished. Commit reports = #{commit_reports.to_json}"

      return {}
    end

    def initialize(task, schema, index)
      puts "Example output thread #{index}..."
      super
      @rows = 0
      @unique_keys = ::Set.new
      @redis = ::Redis.new(:host => task['host'], :port => task['port'], :db => task['db'])
    end

    def close
    end

    def add(page)
      page.each do |record|
        hash = Hash[schema.names.zip(record)]
        k = "#{task['key_prefix']}#{hash[task['key']]}"
        unless @unique_keys.include? k
          case task['encode']
          when 'json'
            v = hash.to_json
            @redis.set(k, v)
          when 'hash'
            @redis.hmset(k, hash.to_a.flatten)
          end
          @unique_keys << k
        else
          puts "Warning: #{k} is already exists"
        end
        @rows += 1  # inrement anyway
      end
    end

    def finish
    end

    def abort
    end

    def commit
      commit_report = {
        "rows" => @rows,
        "unique_keys" => @unique_keys.size
      }
      return commit_report
    end
  end

end
