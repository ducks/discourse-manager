# frozen_string_literal: true

# name: discourse-manager
# about: A community management sim running inside Discourse
# version: 0.1.0
# authors: Jake Goldsborough
# url: https://github.com/ducks/discourse-manager

enabled_site_setting :discourse_manager_enabled

register_asset "stylesheets/discourse-manager.scss"

after_initialize do
  module ::DiscourseManager
    PLUGIN_NAME = "discourse-manager"

    def self.enabled?
      SiteSetting.discourse_manager_enabled
    end
  end

  require_relative "app/controllers/discourse_manager/game_controller"
  require_relative "app/models/discourse_manager/game_session"
  require_relative "app/models/discourse_manager/fake_user"
  require_relative "app/models/discourse_manager/fake_post"
  require_relative "app/models/discourse_manager/game_event"
require_relative "app/jobs/discourse_manager/advance_game_state"
  require_relative "app/jobs/discourse_manager/generate_fake_data"

  Discourse::Application.routes.append do
    get "/play" => "discourse_manager/game#show"
    scope "/discourse-manager" do
      post "/start"  => "discourse_manager/game#start"
      post "/action" => "discourse_manager/game#action"
      get  "/state"  => "discourse_manager/game#state"
    end
  end
end
