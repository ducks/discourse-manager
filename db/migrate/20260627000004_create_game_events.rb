# frozen_string_literal: true

class CreateGameEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_manager_game_events do |t|
      t.integer  :game_session_id, null: false
      t.string   :event_type,      null: false
      t.jsonb    :payload,         null: false, default: {}
      t.boolean  :fired,           null: false, default: false
      t.boolean  :resolved,        null: false, default: false
      t.string   :resolution
      t.datetime :fire_at
      t.datetime :resolved_at
      t.timestamps
    end

    add_index :discourse_manager_game_events, :game_session_id
    add_index :discourse_manager_game_events, [:game_session_id, :fired, :resolved]
  end
end
