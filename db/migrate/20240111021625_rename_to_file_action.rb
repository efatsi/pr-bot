class RenameToFileAction < ActiveRecord::Migration[7.0]
  def change
    rename_column :action_templates, :system_action, :file_action
  end
end
