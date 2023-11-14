class UpdateGeneratedInstructionsToJson < ActiveRecord::Migration[7.0]
  def change
    remove_column :robo_jobs, :generated_instructions, :text
    add_column :robo_jobs, :generated_instructions, :json, default: {}
  end
end
