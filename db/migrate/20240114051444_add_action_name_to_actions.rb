class AddActionNameToActions < ActiveRecord::Migration[7.0]
  def change
    add_column :actions, :action_name, :string
  end
end
