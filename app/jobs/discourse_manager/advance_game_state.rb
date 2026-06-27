# frozen_string_literal: true

module Jobs
  class AdvanceGameState < ::Jobs::Base
    def execute(args)
      session = DiscourseManager::GameSession.find_by(id: args[:game_session_id])
      return unless session&.status == "active"

      session.advance_tick!
      session.publish_state!
    end
  end

  class AdvanceGameDay < ::Jobs::Base
    def execute(args)
      session = DiscourseManager::GameSession.find_by(id: args[:game_session_id])
      return unless session&.status == "active"

      session.end_day!
    end
  end
end
