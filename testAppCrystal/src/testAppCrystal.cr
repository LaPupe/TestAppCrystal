require "kemal"
require "http/client"
require "json"

class Response
  JSON.mapping(
    status: String,
    token: String?,
  )
end

get "/" do
  "Hello World!"
end

post "/connect" do |env|
  data = {
    "login":    env.params.body["email"]?,
    "password": env.params.body["password"]?,
  }.to_json
  response = HTTP::Client.post("http://0.0.0.0:3000/tokens", headers: HTTP::Headers{"Content-Type" => "application/json"}, body: data)
  res = Response.from_json(response.body)
  puts res.status

  if res.status = "success"
    env.redirect "/connectSuccess" # redirect to /login page
  end
end

get "/connect" do
  File.read "src/connect.html"
end

get "/connectSuccess" do
  "Connection successful"
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp "0.0.0.0", 3001, reuse_port: true
end
