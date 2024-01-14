class AddSummaryErrorToActions < ActiveRecord::Migration[7.0]
  def change
    add_column :actions, :summary, :text
    add_column :actions, :error, :text
  end
end
