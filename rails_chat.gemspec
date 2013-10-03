Gem::Specification.new do |s|
  s.name        = "rails_chat"
  s.version     = "1.0.3"
  s.author      = "[CISROR Team, Erfan Mansuri]"
  s.email       = "erfan.m@cisinlabs.com"
  s.homepage    = "http://github.com/ciserfan/rails_chat"
  s.summary     = "RailsChat is a Ruby gem for use with Rails to publish and subscribe to messages through Faye. It allows you to easily provide real-time updates through an open socket without tying up a Rails process. All channels are private so users can only listen to events you subscribe them to. Refrence gem: https://github.com/ryanb/private_pub"
  s.description = "RailsChat is a Ruby gem for use with Rails to publish and subscribe to messages through Faye. It allows you to easily provide real-time updates through an open socket without tying up a Rails process. All channels are private so users can only listen to events you subscribe them to. Refrence gem: https://github.com/ryanb/private_pub"

  s.files        = Dir["{app,lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'faye'
  s.add_dependency 'thin'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'jasmine', '>= 1.1.1'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
