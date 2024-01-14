class RemoveActionTemplateIdFromActions < ActiveRecord::Migration[7.0]
  def change
    remove_column :actions, :action_template_id, :bigint
  end
end
