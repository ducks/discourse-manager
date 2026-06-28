# frozen_string_literal: true

module DiscourseManager
  class GameEvent < ActiveRecord::Base
    self.table_name = "discourse_manager_game_events"

    belongs_to :game_session, class_name: "DiscourseManager::GameSession"

    def config
      EventRegistry.for(event_type) || {}
    end

    def description
      config[:description] || event_type
    end

    def category
      config[:category]&.to_s || "community"
    end

    def icon
      config[:icon] || "⚠️"
    end

    def available_resolutions
      config[:resolutions]&.keys || []
    end

    def as_json(*)
      {
        id:          id,
        event_type:  event_type,
        category:    category,
        icon:        icon,
        description: description,
        payload:     payload,
        resolutions: available_resolutions,
      }
    end
  end
end
