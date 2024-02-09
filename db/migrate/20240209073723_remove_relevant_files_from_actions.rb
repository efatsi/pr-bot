class RemoveRelevantFilesFromActions < ActiveRecord::Migration[7.0]
  def change
    remove_column :actions, :relevant_files, :json
  end
end
