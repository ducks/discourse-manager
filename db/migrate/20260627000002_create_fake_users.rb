# frozen_string_literal: true

class CreateFakeUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_manager_fake_users do |t|
      t.integer :game_session_id, null: false
      t.string  :username,        null: false
      t.string  :display_name,    null: false
      t.string  :avatar_color,    null: false
      t.integer :trust_level,     null: false, default: 0
      t.string  :profile,         null: false # lurker, contributor, troll, spammer, newbie
      t.integer :warnings,        null: false, default: 0
      t.boolean :suspended,       null: false, default: false
      t.boolean :banned,          null: false, default: false
      t.timestamps
    end

    add_index :discourse_manager_fake_users, :game_session_id
  end
end
