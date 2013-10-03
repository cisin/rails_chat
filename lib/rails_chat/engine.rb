require "rails_chat/view_helpers"

module RailsChat
  class Engine < Rails::Engine
    # Loads the rails_chat.yml file if it exists.
    initializer "rails_chat.config" do
      path = Rails.root.join("config/rails_chat.yml")
      RailsChat.load_config(path, Rails.env) if path.exist?
    end

    # Adds the ViewHelpers into ActionView::Base
    initializer "rails_chat.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
