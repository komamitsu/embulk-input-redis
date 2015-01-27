# Embulk input/output plugin for Redis

This [Embulk](https://github.com/embulk/embulk) output plugin writes records to a json column of a table.

This plugin runs without transaction for now.

## Configuration

- **host** host name of the Redis server (string, default: "localhost")
- **port** port of the Redis server (integer, default: 6379)
- **db** destination database number (integer, default: 0)
- **key_prefix** key prefix to search keys for input plugin (string)
- **key** key name for output plugin (string, required)

### Example

```yaml
out:
  type: redis
  host: localhost
  port: 6379
  db: 0
  key: user_name

in:
  type: redis
  host: localhost
  port: 6379
  db: 0
  key_prefix: user_
```

