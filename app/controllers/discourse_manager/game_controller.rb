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
