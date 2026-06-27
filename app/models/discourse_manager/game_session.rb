# frozen_string_literal: true

module DiscourseManager
  class GameSession < ActiveRecord::Base
    self.table_name = "discourse_manager_game_sessions"

    belongs_to :user
    has_many :fake_users,  class_name: "DiscourseManager::FakeUser",  foreign_key: :game_session_id, dependent: :destroy
    has_many :fake_posts,  class_name: "DiscourseManager::FakePost",  foreign_key: :game_session_id, dependent: :destroy
    has_many :game_events, class_name: "DiscourseManager::GameEvent", foreign_key: :game_session_id, dependent: :destroy

    scope :active, -> { where(status: "active") }

    DAY_DURATION   = 3.minutes
    TICK_INTERVAL  = 15.seconds
    MAX_DAYS       = 30

    PROFILES = %w[lurker contributor troll spammer newbie].freeze
    CATEGORIES = %w[general meta support announcements].freeze
    FLAG_TYPES = %w[spam inappropriate off_topic something_else].freeze

    EVENT_TYPES = %w[
      viral_topic
      sockpuppet_wave
      staff_conflict
      spam_wave
      plugin_broken
      great_newcomer
      external_link_spike
    ].freeze

    def self.for_user(user)
      active.find_by(user_id: user.id)
    end

    def pending_flags
      fake_posts.where(flagged: true, flag_resolved: false, removed: false)
    end

    def pending_events
      game_events.where(fired: true, resolved: false)
    end

    def advance_tick!
      apply_flag_decay
      maybe_fire_event
      check_lose_conditions
      save!
    end

    def apply_action!(action, params = {})
      case action
      when "approve_flag"
        resolve_flag(params[:post_id], "approved")
      when "remove_post"
        resolve_flag(params[:post_id], "removed")
      when "warn_user"
        resolve_flag(params[:post_id], "warned")
        warn_fake_user(params[:user_id])
      when "suspend_user"
        resolve_flag(params[:post_id], "suspended")
        suspend_fake_user(params[:user_id])
      when "ban_user"
        resolve_flag(params[:post_id], "banned")
        ban_fake_user(params[:user_id])
      when "resolve_event"
        resolve_event(params[:event_id], params[:resolution])
      end

      update_meters!
      save!
    end

    def start_day!
      ends_at = DAY_DURATION.from_now
      update!(day_ends_at: ends_at)
      schedule_ticks(ends_at)
      Jobs.enqueue_at(ends_at, :advance_game_day, game_session_id: id)
    end

    def end_day!
      if day >= MAX_DAYS
        update!(status: "won")
      else
        update!(day: day + 1)
        start_day!
      end
      publish_state!
    end

    def as_json_state
      {
        id: id,
        day: day,
        score: score,
        status: status,
        meters: { health:, response_time:, spam_rate:, retention: },
        day_ends_at: day_ends_at,
        pending_flags: pending_flags.includes(:fake_user).map(&:as_flag_json),
        pending_events: pending_events.map(&:as_json),
      }
    end

    def publish_state!
      MessageBus.publish("/discourse-manager/session/#{id}", as_json_state)
    end

    private

    def schedule_ticks(ends_at)
      tick_count = (DAY_DURATION / TICK_INTERVAL).to_i
      tick_count.times do |i|
        fire_at = (i + 1) * TICK_INTERVAL
        Jobs.enqueue_at(fire_at.from_now, :advance_game_state, game_session_id: id)
      end
    end

    def apply_flag_decay
      unresolved_count = pending_flags.count
      self.health        = [health - (unresolved_count * 2), 0].max
      self.response_time = [response_time - (unresolved_count * 3), 0].max
    end

    def update_meters!
      spam_posts = fake_posts.where(flag_type: "spam", flag_resolved: false).count
      total_posts = fake_posts.count
      self.spam_rate = total_posts > 0 ? [(spam_posts.to_f / total_posts * 100).to_i, 100].min : 0

      banned_count = fake_users.where(banned: true).count
      self.retention = [100 - (banned_count * 5), 0].max

      self.score = (health + response_time + (100 - spam_rate) + retention) / 4
    end

    def check_lose_conditions
      if health <= 0 || retention <= 0
        update!(status: "lost")
        publish_state!
      end
    end

    def maybe_fire_event
      return if pending_events.count >= 2
      return unless rand < event_probability

      event_type = EVENT_TYPES.sample
      game_events.create!(
        event_type: event_type,
        fired: true,
        fire_at: Time.current,
        payload: build_event_payload(event_type),
      )
      publish_state!
    end

    def event_probability
      base = 0.05
      day_scaling = day * 0.01
      [base + day_scaling, 0.4].min
    end

    def build_event_payload(event_type)
      case event_type
      when "viral_topic"
        post = fake_posts.order("RANDOM()").first
        { post_id: post&.id, flag_count: rand(15..40) }
      when "sockpuppet_wave"
        { count: rand(5..12) }
      when "spam_wave"
        { count: rand(10..20) }
      else
        {}
      end
    end

    def resolve_flag(post_id, resolution)
      post = fake_posts.find_by(id: post_id)
      return unless post
      post.update!(flag_resolved: true, flag_resolution: resolution, removed: resolution == "removed")
      self.response_time = [response_time + 5, 100].min
    end

    def warn_fake_user(user_id)
      user = fake_users.find_by(id: user_id)
      return unless user
      user.increment!(:warnings)
    end

    def suspend_fake_user(user_id)
      fake_users.find_by(id: user_id)&.update!(suspended: true)
    end

    def ban_fake_user(user_id)
      fake_users.find_by(id: user_id)&.update!(banned: true)
      self.retention = [retention - 10, 0].max
    end

    def resolve_event(event_id, resolution)
      event = game_events.find_by(id: event_id)
      return unless event
      event.update!(resolved: true, resolution: resolution, resolved_at: Time.current)
      apply_event_resolution(event, resolution)
    end

    def apply_event_resolution(event, resolution)
      case event.event_type
      when "viral_topic"
        self.health = resolution == "close_topic" ? [health + 10, 100].min : [health - 5, 0].max
      when "sockpuppet_wave"
        self.spam_rate = resolution == "ban_all" ? [spam_rate - 20, 0].max : [spam_rate + 10, 100].min
      when "staff_conflict"
        self.retention = resolution == "mediate" ? [retention + 5, 100].min : [retention - 10, 0].max
      end
    end
  end
end
