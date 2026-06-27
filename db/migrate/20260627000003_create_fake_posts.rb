# frozen_string_literal: true

class CreateFakePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_manager_fake_posts do |t|
      t.integer :game_session_id,  null: false
      t.integer :fake_user_id,     null: false
      t.string  :topic_title
      t.text    :body,             null: false
      t.string  :category,         null: false, default: "general"
      t.boolean :is_topic_op,      null: false, default: false
      t.boolean :flagged,          null: false, default: false
      t.string  :flag_type                                    # spam, inappropriate, off_topic, something_else
      t.boolean :flag_resolved,    null: false, default: false
      t.string  :flag_resolution                              # approved, removed, warned
      t.boolean :removed,          null: false, default: false
      t.timestamps
    end

    add_index :discourse_manager_fake_posts, :game_session_id
    add_index :discourse_manager_fake_posts, :fake_user_id
    add_index :discourse_manager_fake_posts, [:game_session_id, :flagged, :flag_resolved]
  end
end
