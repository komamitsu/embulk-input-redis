# Embulk input/output plugin for Redis

This [Embulk](https://github.com/embulk/embulk) output plugin writes records to a json column of a table.

This plugin runs without transaction for now.

## Configuration

- **host** Hostname of the Redis server (string, default: "localhost")
- **port** Port of the Redis server (integer, default: 6379)
- **db** Database number (integer, default: 0)
- **key_prefix** Key prefix for input/output plugin (string)
- **encode** Encoding in Redis
 - json: Stored as a JSON string. GET/SET commands can access it (string)
 - hash: Stored as a Hash. H* commands such as HMGET/HMSET can access it (string, output only)
- **key** Column name used for a key in Redis (string, required: output only)

### Example

```yaml
out:
  type: redis
  host: localhost
  port: 6379
  db: 0
  key: user_name
  key_prefix: user_
  encode: hash

in:
  type: redis
  host: localhost
  port: 6379
  db: 0
  key_prefix: user_
  encode: json
```

