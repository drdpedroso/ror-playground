require_relative 'config/environment'
require 'puma'

puts "Starting Gym Class Management Server..."
puts "Visit: http://localhost:3000"

port = ENV['PORT'] || 3000

app = Rack::Builder.new do
  run Rails.application
end

Rack::Handler::Puma.run(app.call, Port: port, Host: '0.0.0.0')