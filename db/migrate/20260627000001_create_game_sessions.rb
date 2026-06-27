# frozen_string_literal: true

class CreateGameSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_manager_game_sessions do |t|
      t.integer  :user_id,       null: false
      t.integer  :day,           null: false, default: 1
      t.integer  :score,         null: false, default: 0
      t.integer  :health,        null: false, default: 100
      t.integer  :response_time, null: false, default: 100
      t.integer  :spam_rate,     null: false, default: 0
      t.integer  :retention,     null: false, default: 100
      t.string   :status,        null: false, default: "active" # active, won, lost
      t.datetime :day_ends_at
      t.timestamps
    end

    add_index :discourse_manager_game_sessions, :user_id
    add_index :discourse_manager_game_sessions, :status
  end
end
