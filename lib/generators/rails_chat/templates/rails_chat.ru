# Run with: rackup rails_chat.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "rails_chat"

Faye::WebSocket.load_adapter('thin')

RailsChat.load_config(File.expand_path("../config/rails_chat.yml", __FILE__), ENV["RAILS_ENV"] || "development")
run RailsChat.faye_app
