class AddRoboEventToContextualFiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :contextual_files, :robo_event, null: false, foreign_key: true
  end
end
