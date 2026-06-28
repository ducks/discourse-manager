# frozen_string_literal: true

module DiscourseManager
  module EventRegistry
    EVENTS = {
      "viral_topic" => {
        category: :community,
        icon: "🔥",
        description: "A heated topic is exploding. Flags are coming in fast.",
        on_fire: ->(s) { s.spawn_new_flags(count: rand(15..40)) },
        resolutions: {
          "close_topic"   => ->(s) { s.health        = [s.health + 10, 100].min },
          "let_it_ride"   => ->(s) { s.health        = [s.health - 5,    0].max },
          "pin_response"  => ->(s) { s.health        = [s.health + 3,  100].min },
        },
      },
      "sockpuppet_wave" => {
        category: :community,
        icon: "👥",
        description: "Multiple new accounts were created in the last few minutes. They all post the same thing.",
        on_fire: ->(s) {
          rand(5..12).times do
            user = s.fake_users.create!(
              username:     DiscourseManager::FakeUser.generate_username,
              display_name: DiscourseManager::FakeUser.generate_display_name,
              avatar_color: DiscourseManager::FakeUser::AVATAR_COLORS.sample,
              trust_level:  0,
              profile:      "spammer",
              warnings:     0,
              suspended:    false,
              banned:       false,
            )
            s.fake_posts.create!(
              fake_user:     user,
              body:          DiscourseManager::FakePost.post_body_for(user),
              category:      DiscourseManager::GameSession::CATEGORIES.sample,
              is_topic_op:   false,
              flagged:       true,
              flag_type:     "spam",
              flag_resolved: false,
              removed:       false,
            )
          end
        },
        resolutions: {
          "ban_all"     => ->(s) { s.spam_rate = [s.spam_rate - 20,  0].max },
          "investigate" => ->(s) { s.spam_rate = [s.spam_rate + 10, 100].min },
          "ignore"      => ->(s) { s.spam_rate = [s.spam_rate + 10, 100].min },
        },
      },
      "staff_conflict" => {
        category: :community,
        icon: "⚔️",
        description: "Two of your most trusted users are publicly fighting in a thread.",
        on_fire: ->(s) { s.health = [s.health - 5, 0].max },
        resolutions: {
          "mediate"    => ->(s) { s.retention = [s.retention + 5,  100].min },
          "take_sides" => ->(s) { s.retention = [s.retention - 10,   0].max },
          "ignore"     => ->(s) { s.retention = [s.retention - 5,    0].max },
        },
      },
      "spam_wave" => {
        category: :community,
        icon: "📨",
        description: "A wave of spam posts just hit the forum.",
        on_fire: ->(s) { s.spawn_new_flags(count: rand(10..20)) },
        resolutions: {
          "mass_remove"    => ->(s) { s.spam_rate = [s.spam_rate - 15,  0].max },
          "silently_delete" => ->(s) { s.spam_rate = [s.spam_rate - 10, 0].max },
          "warn_all"       => ->(s) { s.spam_rate = [s.spam_rate - 5,   0].max },
        },
      },
      "plugin_broken" => {
        category: :community,
        icon: "🔌",
        description: "Users are reporting that something is broken. The complaints thread is growing.",
        on_fire: ->(s) { s.response_time = [s.response_time - 15, 0].max },
        resolutions: {
          "post_update"    => ->(s) { s.health    = [s.health + 5,    100].min },
          "rollback_plugin" => ->(s) { s.response_time = [s.response_time + 15, 100].min },
          "ignore"         => ->(s) { s.health    = [s.health - 10,     0].max },
        },
      },
      "great_newcomer" => {
        category: :community,
        icon: "🌟",
        description: "A new user just posted something genuinely helpful and thoughtful.",
        on_fire: ->(s) { s.retention = [s.retention + 5, 100].min },
        resolutions: {
          "welcome"        => ->(s) { s.retention = [s.retention + 5,  100].min },
          "promote_tl1"    => ->(s) { s.health    = [s.health + 5,     100].min },
          "ignore"         => ->(s) {},
        },
      },
      "external_link_spike" => {
        category: :community,
        icon: "📈",
        description: "Your forum was linked from somewhere big. New registrations are spiking.",
        on_fire: ->(s) { s.spawn_new_flags(count: rand(3..8)) },
        resolutions: {
          "pin_welcome_topic"  => ->(s) { s.retention = [s.retention + 10, 100].min },
          "lock_registrations" => ->(s) { s.spam_rate = [s.spam_rate - 10,   0].max },
          "do_nothing"         => ->(s) { s.spam_rate = [s.spam_rate + 5,  100].min },
        },
      },
      "bad_update" => {
        category: :technical,
        icon: "💥",
        description: "A plugin update just shipped and users are reporting broken features. The error log is full.",
        on_fire: ->(s) {
          s.response_time = [s.response_time - 30, 0].max
          s.health        = [s.health - 10,         0].max
        },
        resolutions: {
          "rollback_update"   => ->(s) {
            s.response_time = [s.response_time + 25, 100].min
            s.health        = [s.health + 5,         100].min
          },
          "hotfix_live"       => ->(s) {
            if rand < 0.5
              s.response_time = [s.response_time + 35, 100].min
            else
              s.response_time = [s.response_time - 10,   0].max
              s.health        = [s.health - 10,           0].max
            end
          },
          "post_status_update" => ->(s) {
            s.health    = [s.health + 5,    100].min
            s.retention = [s.retention + 5, 100].min
          },
        },
      },
      "server_outage" => {
        category: :technical,
        icon: "🔴",
        description: "The forum just went down. Users are posting on Twitter asking what happened.",
        on_fire: ->(s) {
          s.response_time = [s.response_time - 50, 0].max
          s.health        = [s.health - 20,         0].max
        },
        resolutions: {
          "escalate_immediately"   => ->(s) {
            s.response_time = [s.response_time + 40, 100].min
            s.health        = [s.health + 10,        100].min
          },
          "post_maintenance_notice" => ->(s) {
            s.health    = [s.health + 5,    100].min
            s.retention = [s.retention + 5, 100].min
          },
          "wait_and_see"           => ->(s) { s.retention = [s.retention - 15, 0].max },
        },
      },
      "db_migration_fail" => {
        category: :technical,
        icon: "🗄️",
        description: "A database migration ran in production and something went wrong. Posting is broken for some users.",
        on_fire: ->(s) {
          s.response_time = [s.response_time - 20,  0].max
          s.spam_rate     = [s.spam_rate + 15,     100].min
        },
        resolutions: {
          "restore_backup"    => ->(s) {
            s.response_time = [s.response_time + 20, 100].min
            s.spam_rate     = [s.spam_rate - 10,       0].max
          },
          "disable_writes"    => ->(s) {
            s.response_time = [s.response_time + 10, 100].min
            s.retention     = [s.retention - 10,       0].max
          },
          "communicate_openly" => ->(s) {
            s.health    = [s.health + 5,    100].min
            s.retention = [s.retention + 5, 100].min
          },
        },
      },
      "cdn_failure" => {
        category: :technical,
        icon: "🌐",
        description: "Images and attachments are failing to load. The forum looks broken to everyone.",
        on_fire: ->(s) {
          s.retention = [s.retention - 20, 0].max
          s.health    = [s.health - 10,     0].max
        },
        resolutions: {
          "purge_cdn_cache"     => ->(s) {
            s.retention = [s.retention + 15, 100].min
            s.health    = [s.health + 5,     100].min
          },
          "switch_cdn_provider" => ->(s) { s.retention = [s.retention + 10, 100].min },
          "post_workaround"     => ->(s) { s.retention = [s.retention + 5,  100].min },
        },
      },
      "accidental_data_wipe" => {
        category: :technical,
        icon: "🚨",
        description: "A cleanup script ran with the wrong scope. Several categories of posts are gone.",
        on_fire: ->(s) {
          s.health    = [s.health - 35,    0].max
          s.retention = [s.retention - 25, 0].max
        },
        resolutions: {
          "restore_from_backup" => ->(s) {
            s.health    = [s.health + 20,    100].min
            s.retention = [s.retention + 15, 100].min
          },
          "notify_users"  => ->(s) {
            s.health    = [s.health + 5,    100].min
            s.retention = [s.retention - 5,   0].max
          },
          "cover_it_up"   => ->(s) {
            s.retention = [s.retention - 30, 0].max
            s.health    = [s.health - 10,     0].max
          },
        },
      },
    }.freeze

    def self.all_types
      EVENTS.keys
    end

    def self.for(event_type)
      EVENTS[event_type]
    end
  end
end
