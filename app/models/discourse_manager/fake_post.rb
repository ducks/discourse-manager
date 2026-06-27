# frozen_string_literal: true

module DiscourseManager
  class FakePost < ActiveRecord::Base
    self.table_name = "discourse_manager_fake_posts"

    belongs_to :game_session, class_name: "DiscourseManager::GameSession"
    belongs_to :fake_user,    class_name: "DiscourseManager::FakeUser"

    scope :pending_flags, -> { where(flagged: true, flag_resolved: false, removed: false) }

    CONTENT_BY_PROFILE = {
      "spammer" => [
        "Check out this amazing deal! Click here: http://totally-real-site.biz",
        "I make $4000/week working from home. DM me for details.",
        "FREE GIFT CARDS just fill out this survey!!!",
      ],
      "troll" => [
        "This forum is honestly a joke. The mods don't know what they're doing.",
        "Anyone who disagrees with me is just wrong, full stop. Stop embarrassing yourselves.",
        "Hot take: everything about the way this community is run is a disaster.",
      ],
      "contributor" => [
        "I've been thinking about this a lot and I think the key issue is how we handle new users.",
        "Great point! I'd add that the documentation could really use some work in this area.",
        "Has anyone else noticed that performance has been worse lately? Here's what I found.",
      ],
      "lurker" => [
        "First post here - been reading for a while. Finally made an account to say thanks!",
        "Sorry if this has been asked before, but can anyone help me with this?",
        "+1 to this, same thing happened to me.",
      ],
      "newbie" => [
        "HOW DO I CHANGE MY USERNAME?? I've been trying for 20 minutes!!",
        "Is this forum even active?? Hello??? Anyone here???",
        "Can someone explain how trust levels work I don't get it",
      ],
    }.freeze

    TOPIC_TITLES = [
      "Why has the community been so toxic lately?",
      "Appreciation post - this forum has helped me so much",
      "Bug report: can't upload images on mobile",
      "Unpopular opinion: we need stricter rules",
      "What's everyone's favorite feature of this forum?",
      "Mods are asleep, post your unhinged takes",
      "New here - quick question about the rules",
      "This community is going downhill and here's why",
      "Weekly check-in thread - how's everyone doing?",
      "Suggestion: we should have a dedicated off-topic category",
    ].freeze

    def self.generate_for_session(session)
      users = session.fake_users.to_a
      posts = []

      TOPIC_TITLES.each do |title|
        author = users.sample
        posts << {
          game_session_id: session.id,
          fake_user_id: author.id,
          topic_title: title,
          body: post_body_for(author),
          category: GameSession::CATEGORIES.sample,
          is_topic_op: true,
          flagged: should_flag?(author),
          flag_type: flag_type_for(author),
          flag_resolved: false,
          removed: false,
          created_at: Time.current,
          updated_at: Time.current,
        }

        rand(1..5).times do
          reply_author = users.sample
          posts << {
            game_session_id: session.id,
            fake_user_id: reply_author.id,
            topic_title: nil,
            body: post_body_for(reply_author),
            category: GameSession::CATEGORIES.sample,
            is_topic_op: false,
            flagged: should_flag?(reply_author),
            flag_type: flag_type_for(reply_author),
            flag_resolved: false,
            removed: false,
            created_at: Time.current,
            updated_at: Time.current,
          }
        end
      end

      insert_all(posts)
    end

    def self.post_body_for(user)
      pool = CONTENT_BY_PROFILE[user.profile] || CONTENT_BY_PROFILE["lurker"]
      pool.sample
    end

    def self.should_flag?(user)
      case user.profile
      when "spammer" then rand < 0.9
      when "troll"   then rand < 0.6
      when "newbie"  then rand < 0.1
      else                rand < 0.02
      end
    end

    def self.flag_type_for(user)
      return nil unless should_flag?(user)
      case user.profile
      when "spammer" then "spam"
      when "troll"   then %w[inappropriate off_topic].sample
      else                GameSession::FLAG_TYPES.sample
      end
    end

    def as_flag_json
      {
        id: id,
        body: body,
        topic_title: topic_title,
        category: category,
        flag_type: flag_type,
        fake_user: {
          id: fake_user.id,
          username: fake_user.username,
          display_name: fake_user.display_name,
          avatar_color: fake_user.avatar_color,
          letter: fake_user.letter_avatar,
          trust_level: fake_user.trust_level,
          profile: fake_user.profile,
          warnings: fake_user.warnings,
          suspended: fake_user.suspended,
          banned: fake_user.banned,
        },
      }
    end
  end
end
