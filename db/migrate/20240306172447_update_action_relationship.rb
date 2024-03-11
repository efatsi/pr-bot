class UpdateActionRelationship < ActiveRecord::Migration[7.0]
  def up
    # remove all actions
    Action.destroy_all

    remove_reference :actions, :robo_job, index: true, foreign_key: true
    add_reference :actions, :robo_request, index: true, foreign_key: true
  end

  def down
    remove_reference :actions, :robo_request, index: true, foreign_key: true
    add_reference :actions, :robo_job, index: true, foreign_key: true
  end
end
