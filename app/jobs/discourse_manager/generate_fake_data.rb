# frozen_string_literal: true

module Jobs
  class GenerateFakeData < ::Jobs::Base
    def execute(args)
      session = DiscourseManager::GameSession.find_by(id: args[:game_session_id])
      return unless session

      DiscourseManager::FakeUser.generate_for_session(session, count: 40)
      DiscourseManager::FakePost.generate_for_session(session)

      session.start_day!
      session.publish_state!
    end
  end
end
