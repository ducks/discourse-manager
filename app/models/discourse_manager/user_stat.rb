# frozen_string_literal: true

module DiscourseManager
  class UserStat < ActiveRecord::Base
    self.table_name = "discourse_manager_user_stats"

    belongs_to :user

    def self.record_game_end(user:, score:, day:)
      stat = find_or_initialize_by(user_id: user.id)
      stat.games_played += 1
      stat.high_score = score if score > stat.high_score
      stat.best_day = day if day > stat.best_day
      stat.save!
      stat
    end

    def self.leaderboard(limit: 10)
      joins("JOIN users ON users.id = discourse_manager_user_stats.user_id")
        .order(high_score: :desc)
        .limit(limit)
        .select("discourse_manager_user_stats.*, users.username")
    end
  end
end
