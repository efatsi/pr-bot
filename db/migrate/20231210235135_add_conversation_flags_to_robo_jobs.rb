class AddConversationFlagsToRoboJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_jobs, :include_last_convo, :boolean, default: false
    add_column :robo_jobs, :include_all_convos, :boolean, default: false
  end
end
