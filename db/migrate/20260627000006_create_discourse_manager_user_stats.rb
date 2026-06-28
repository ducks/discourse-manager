# frozen_string_literal: true

class CreateDiscourseManagerUserStats < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_manager_user_stats do |t|
      t.integer :user_id, null: false
      t.integer :high_score, null: false, default: 0
      t.integer :games_played, null: false, default: 0
      t.integer :best_day, null: false, default: 0
      t.timestamps
    end

    add_index :discourse_manager_user_stats, :user_id, unique: true
    add_index :discourse_manager_user_stats, :high_score
  end
end
