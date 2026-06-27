# frozen_string_literal: true

class AddDaySummaryToGameSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :discourse_manager_game_sessions, :day_summary, :jsonb
  end
end
