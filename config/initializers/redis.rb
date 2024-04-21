# frozen_string_literal: true
return if ENV["RAILS_WEB"]
Redis.sadd_returns_boolean = false
