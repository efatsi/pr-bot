class AddRelevantFilesToActions < ActiveRecord::Migration[7.0]
  def change
    add_column :actions, :relevant_files, :json
  end
end
