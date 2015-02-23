require "connection_pool"

module RedisUtil
	def self.connect(pool_size = 5)
		begin
			ENV["REDIS_URI"] = "redis://localhost:6379"
			uri = URI.parse ENV["REDIS_URI"]
			$redis = ConnectionPool::Wrapper.new(:size => pool_size, :timeout => 10) { Redis.connect(:host => uri.host, :port => uri.port, :password => uri.password) }
		rescue => e
			raise e
			# Rails.logger.error "RedisUtil.connect failed :: #{e}"
		end
		$redis
	end
end