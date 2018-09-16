require "kemal"

get "/" do
  "Hello World!"
end

post "/connect" do
  File.read "src/connect.html"
end

get "/connect" do
  File.read "src/connect.html"
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp "0.0.0.0", 3001, reuse_port: true
end
