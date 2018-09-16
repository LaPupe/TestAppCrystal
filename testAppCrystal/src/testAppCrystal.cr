require "kemal"
require "http/client"
require "json"
require "html_builder"

class Response
  JSON.mapping(
    status: String,
    token: String?,
  )
end

def templateBody(&block)
  HTML.build do
    doctype

    html do
      head do
        html "<meta charset=\"utf-8\"/>"
        link(href: "https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.1/css/bulma.min.css", rel: "stylesheet")
      end

      body do
        div(class: "navbar is-light") do
          div(class: "navbar-brand") do
            a(href: "/") do
              h1(class: "title") do
                text "Lala — Online"
              end
            end
          end
          div(class: "navbar-menu") do
            div(class: "navbar-end") do
              a(class: "navbar-item", href: "/connect") do
                text "Login"
              end
            end
          end
        end

        div(class: "section") do
          div(class: "container") do
            html yield
          end
        end
      end
    end
  end
end

get "/" do
  templateBody do
    HTML.build do
      text "Hello, world!"
    end
  end
end

def connect_page
  templateBody do
    HTML.build do
      form(action: "/connect") do
        div(class: "field") do
          label(class: "label") { text "Email" }
          input(class: "input", type: "text", name: "email")
        end

        div(class: "field") do
          label(class: "label") { text "Password" }
          input(class: "input", type: "password", name: "password")
        end

        div(class: "field is-grouped") do
          input(class: "button is-link", type: "submit", value: "Submit")
        end
      end
    end
  end
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
    env.redirect "/connect" # redirect to /login page
  end
end

get "/connect" do
  "Connection successful"
end

Kemal.run do |config|
  server = config.server.not_nil!
  server.bind_tcp "0.0.0.0", 3001, reuse_port: true
end
