class AddPromptMessagesToRoboRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_requests, :prompt_messages, :json, default: []
    remove_column :robo_requests, :prompt, :text
  end
end
