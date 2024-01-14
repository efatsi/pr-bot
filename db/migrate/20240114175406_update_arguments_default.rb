class UpdateArgumentsDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :actions, :arguments, {}
    change_column_default :robo_jobs, :generated_plan, {}
  end
end
