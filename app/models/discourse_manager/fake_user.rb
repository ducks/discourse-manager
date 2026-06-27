# frozen_string_literal: true

module DiscourseManager
  class FakeUser < ActiveRecord::Base
    self.table_name = "discourse_manager_fake_users"

    belongs_to :game_session, class_name: "DiscourseManager::GameSession"
    has_many :fake_posts, class_name: "DiscourseManager::FakePost", foreign_key: :fake_user_id

    AVATAR_COLORS = %w[#3AB795 #A0C4FF #FFD6A5 #FFADAD #BDB2FF #CAFFBF #9BF6FF #FFC6FF #FDFFB6].freeze

    def self.generate_for_session(session, count: 40)
      users = count.times.map do
        profile = weighted_profile
        {
          game_session_id: session.id,
          username: generate_username,
          display_name: generate_display_name,
          avatar_color: AVATAR_COLORS.sample,
          trust_level: profile_trust_level(profile),
          profile: profile,
          warnings: 0,
          suspended: false,
          banned: false,
          created_at: Time.current,
          updated_at: Time.current,
        }
      end
      insert_all(users)
    end

    def self.weighted_profile
      roll = rand(100)
      case roll
      when 0..39  then "lurker"
      when 40..64 then "contributor"
      when 65..79 then "newbie"
      when 80..89 then "troll"
      else             "spammer"
      end
    end

    def self.profile_trust_level(profile)
      case profile
      when "contributor" then rand(2..4)
      when "lurker"      then rand(1..2)
      when "newbie"      then 0
      when "troll"       then rand(1..3)
      when "spammer"     then 0
      end
    end

    def self.generate_username
      adjectives = %w[happy sleepy grumpy quiet loud rapid golden silver bronze crimson]
      nouns = %w[fox bear wolf hawk eagle panda koala raven lynx otter]
      "#{adjectives.sample}_#{nouns.sample}#{rand(10..999)}"
    end

    def self.generate_display_name
      first = %w[Alex Jordan Sam Casey Riley Morgan Taylor Quinn Blake Cameron]
      last  = %w[Smith Jones Lee Park Kim Chen Walsh Murphy Okafor Nguyen]
      "#{first.sample} #{last.sample}"
    end

    def letter_avatar
      display_name.first.upcase
    end
  end
end
