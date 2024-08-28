require 'dotenv'
Dotenv.load
require 'dashing'
require 'logger'


configure do
  set :auth_token, ENV['AUTH_TOKEN']

  set :history_file, File.expand_path('/usr/dashboard/history.yml')

  helpers do
    def protected!
      #settings.logger.info "I'm inside a helper"
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

puts settings.history_file # -> history.yml

if File.exists?(settings.history_file)
  set history: YAML.load_file(settings.history_file)
else
  set history: {}
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
