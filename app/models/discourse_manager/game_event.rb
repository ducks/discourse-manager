# frozen_string_literal: true

module DiscourseManager
  class GameEvent < ActiveRecord::Base
    self.table_name = "discourse_manager_game_events"

    belongs_to :game_session, class_name: "DiscourseManager::GameSession"

    RESOLUTIONS = {
      "viral_topic"         => %w[close_topic let_it_ride pin_response],
      "sockpuppet_wave"     => %w[ban_all investigate ignore],
      "staff_conflict"      => %w[mediate take_sides ignore],
      "spam_wave"           => %w[mass_remove silently_delete warn_all],
      "plugin_broken"       => %w[post_update rollback_plugin ignore],
      "great_newcomer"      => %w[welcome promote_tl1 ignore],
      "external_link_spike" => %w[pin_welcome_topic lock_registrations do_nothing],
      "bad_update"          => %w[rollback_update hotfix_live post_status_update],
      "server_outage"       => %w[escalate_immediately post_maintenance_notice wait_and_see],
      "db_migration_fail"   => %w[restore_backup disable_writes communicate_openly],
      "cdn_failure"         => %w[purge_cdn_cache switch_cdn_provider post_workaround],
      "accidental_data_wipe" => %w[restore_from_backup notify_users cover_it_up],
    }.freeze

    DESCRIPTIONS = {
      "viral_topic"         => "A heated topic is exploding. Flags are coming in fast.",
      "sockpuppet_wave"     => "Multiple new accounts were created in the last few minutes. They all post the same thing.",
      "staff_conflict"      => "Two of your most trusted users are publicly fighting in a thread.",
      "spam_wave"           => "A wave of spam posts just hit the forum.",
      "plugin_broken"       => "Users are reporting that something is broken. The complaints thread is growing.",
      "great_newcomer"      => "A new user just posted something genuinely helpful and thoughtful.",
      "external_link_spike" => "Your forum was linked from somewhere big. New registrations are spiking.",
      "bad_update"          => "A plugin update just shipped and users are reporting broken features. The error log is full.",
      "server_outage"       => "The forum just went down. Users are posting on Twitter asking what happened.",
      "db_migration_fail"   => "A database migration ran in production and something went wrong. Posting is broken for some users.",
      "cdn_failure"         => "Images and attachments are failing to load. The forum looks broken to everyone.",
      "accidental_data_wipe" => "A cleanup script ran with the wrong scope. Several categories of posts are gone.",
    }.freeze

    def description
      DESCRIPTIONS[event_type] || event_type
    end

    def available_resolutions
      RESOLUTIONS[event_type] || []
    end

    TECHNICAL_EVENTS = %w[bad_update server_outage db_migration_fail cdn_failure accidental_data_wipe].freeze

    ICONS = {
      "viral_topic"         => "🔥",
      "sockpuppet_wave"     => "👥",
      "staff_conflict"      => "⚔️",
      "spam_wave"           => "📨",
      "plugin_broken"       => "🔌",
      "great_newcomer"      => "🌟",
      "external_link_spike" => "📈",
      "bad_update"          => "💥",
      "server_outage"       => "🔴",
      "db_migration_fail"   => "🗄️",
      "cdn_failure"         => "🌐",
      "accidental_data_wipe" => "🚨",
    }.freeze

    def category
      TECHNICAL_EVENTS.include?(event_type) ? "technical" : "community"
    end

    def icon
      ICONS[event_type] || "⚠️"
    end

    def as_json(*)
      {
        id: id,
        event_type: event_type,
        category: category,
        icon: icon,
        description: description,
        payload: payload,
        resolutions: available_resolutions,
      }
    end
  end
end
