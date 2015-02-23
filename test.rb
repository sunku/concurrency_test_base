#!/usr/bin/env ruby
require "redis"
require 'active_support/all'
Dir[File.dirname(__FILE__) + '/app/utils/*.rb'].each {|file| require file }

# Init thread pool & mutex
p = ThreadPool.new(5)
mutex = Mutex.new

# Init redis connection
redis = RedisUtil.connect(10)
test_key = "concurrency_test"

# Set default data
redis.set test_key, {level: 0, score: 0}.to_json

(1..10).each do |i|
	p.schedule do    
		# Add codes
		
	end
end

at_exit { 	
  p.shutdown 
}