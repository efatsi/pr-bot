class RenameActionNameToType < ActiveRecord::Migration[7.0]
  def change
    rename_column :actions, :action_name, :type
  end
end
