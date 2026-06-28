# frozen_string_literal: true

module DiscourseManager
  class GameController < ::ApplicationController
    requires_plugin DiscourseManager::PLUGIN_NAME
    before_action :ensure_logged_in

    def show
    end

    def start
      existing = GameSession.for_user(current_user)
      existing&.update!(status: "abandoned")

      session = GameSession.create!(user: current_user)

      Jobs.enqueue(:generate_fake_data, game_session_id: session.id)

      render json: { session_id: session.id, status: "generating" }
    end

    def leaderboard
      rows = DiscourseManager::UserStat.leaderboard
      render json: rows.map { |s|
        { username: s.username, high_score: s.high_score, best_day: s.best_day, games_played: s.games_played }
      }
    end

    def my_stats
      stat = DiscourseManager::UserStat.find_by(user_id: current_user.id)
      if stat
        render json: { high_score: stat.high_score, best_day: stat.best_day, games_played: stat.games_played }
      else
        render json: { high_score: 0, best_day: 0, games_played: 0 }
      end
    end

    def next_day
      session = GameSession.find_by(user_id: current_user.id, status: "day_end")
      return render json: { error: "No day_end session" }, status: 404 unless session

      session.start_next_day!
      render json: session.as_json_state
    end

    def action
      session = current_game_session
      return render json: { error: "No active session" }, status: 404 unless session

      session.apply_action!(params[:action_type], action_params)
      session.publish_state!

      render json: session.as_json_state
    end

    def state
      session = current_game_session
      return render json: { error: "No active session" }, status: 404 unless session

      render json: session.as_json_state
    end

    private

    def current_game_session
      GameSession.active.find_by(user_id: current_user.id)
    end

    def action_params
      params.permit(:post_id, :user_id, :event_id, :resolution).to_h.symbolize_keys
    end
  end
end
