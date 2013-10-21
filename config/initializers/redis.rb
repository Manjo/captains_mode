require "redis"

redis_path = Rails.root.join("config/redis", "#{Rails.env}.conf")

redis_conf = File.read(redis_path)

port = /port.(\d+)/.match(redis_conf)[1]
`redis-server #{redis_path}`
res = `ps aux | grep redis-server`

unless res.include?("redis-server #{redis_path}")
  raise "Couldn't start redis"
end

REDIS_PORT = port