class AddIgnoredFilesToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :ignored_files, :string, array: true, default: []
  end
end
