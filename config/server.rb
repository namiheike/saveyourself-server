# TODO conf based on environments: https://github.com/postrank-labs/goliath/wiki/Configuration
# TODO use EM-Synchrony-Moped instead

require 'moped'

environment :production do
  config['moped'] = EM::Synchrony::ConnectionPool.new(size: 10) do
    Moped::Session.new([ "localhost:27017" ], database: "saveyourself_production")
  end
end

environment :development do
  config['moped'] = EM::Synchrony::ConnectionPool.new(size: 10) do
    Moped::Session.new([ "localhost:27017" ], database: "saveyourself_development")
  end
end

environment :test do
end