ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class IntegrationTest < ActiveSupport::TestCase
  require 'capybara/poltergeist'
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  
  # Capybara.current_driver = :poltergeist
  teardown do
    ActionMailer::Base.deliveries = []
  end
  
  # Allows :js => true on describe, but only for RSpec apparently
  # Capybara.javascript_driver = :poltergeist
  
  # def login_as(user)
  #   OmniAuth.config.add_mock :twitter, {
  #     provider: 'twitter',
  #     uid: user.twitter_uid,
  #     info: {
  #       nickname: user.twitter_nickname,
  #       name: user.twitter_name,
  #       location: user.twitter_location,
  #       image: user.twitter_image
  #     },
  #     credentials: {
  #       auth_token: "1234567890"
  #     }
  #   }
  #   visit "/auth/twitter"
  # end
  
end

class ActiveSupport::TestCase
end