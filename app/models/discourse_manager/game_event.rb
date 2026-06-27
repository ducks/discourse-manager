# frozen_string_literal: true

module DiscourseManager
  class GameEvent < ActiveRecord::Base
    self.table_name = "discourse_manager_game_events"

    belongs_to :game_session, class_name: "DiscourseManager::GameSession"

    RESOLUTIONS = {
      "viral_topic"       => %w[close_topic let_it_ride pin_response],
      "sockpuppet_wave"   => %w[ban_all investigate ignore],
      "staff_conflict"    => %w[mediate take_sides ignore],
      "spam_wave"         => %w[mass_remove silently_delete warn_all],
      "plugin_broken"     => %w[post_update rollback_plugin ignore],
      "great_newcomer"    => %w[welcome promote_tl1 ignore],
      "external_link_spike" => %w[pin_welcome_topic lock_registrations do_nothing],
    }.freeze

    DESCRIPTIONS = {
      "viral_topic"       => "A heated topic is exploding. Flags are coming in fast.",
      "sockpuppet_wave"   => "Multiple new accounts were created in the last few minutes. They all post the same thing.",
      "staff_conflict"    => "Two of your most trusted users are publicly fighting in a thread.",
      "spam_wave"         => "A wave of spam posts just hit the forum.",
      "plugin_broken"     => "Users are reporting that something is broken. The complaints thread is growing.",
      "great_newcomer"    => "A new user just posted something genuinely helpful and thoughtful.",
      "external_link_spike" => "Your forum was linked from somewhere big. New registrations are spiking.",
    }.freeze

    def description
      DESCRIPTIONS[event_type] || event_type
    end

    def available_resolutions
      RESOLUTIONS[event_type] || []
    end

    def as_json(*)
      {
        id: id,
        event_type: event_type,
        description: description,
        payload: payload,
        resolutions: available_resolutions,
      }
    end
  end
end
