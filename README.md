# Embulk input plugin for Redis

## Generic

### Overview

* **Plugin type**: input
* **Resume supported**: no

## Configuration

- **host**: Hostname of the Redis server (string, default: "localhost")
- **port**: Port of the Redis server (integer, default: 6379)
- **db**: Database number (integer, default: 0)
- **key_prefix**: Key prefix for input/output plugin (string, default:"")
- **encode**: Encoding in Redis (string, default: "json")
 - json: Stored as a JSON string. GET/SET commands can access it
 - hash: Stored as a Hash. H* commands such as HMGET/HMSET can access it
- **columns**: Hash records that has the following two fields (array, default:[])
 - name: Name of the column
 - type: Column types as follows
    - boolean
    - long
    - double
    - string
    - timestamp

### Example

```yaml
in:
  type: redis
  host: localhost
  port: 6379
  db: 0
  key_prefix: user_
  encode: json
  columns:
  - {name: id, type: long}
  - {name: account, type: long}
  - {name: time, type: timestamp}
  - {name: purchase, type: timestamp}
  - {name: comment, type: string}
  - {name: admin, type: boolean}
```
