class ChangeRoboRequestsToPolymorphic < ActiveRecord::Migration[7.0]
  def change
    add_reference :robo_requests, :parent, polymorphic: true

    # Backfill existing records to associate with 'robo_job'
    RoboRequest.all.each do |robo_request|
      robo_request.update!(parent_id: robo_request.robo_job_id, parent_type: "RoboJob")
    end

    change_column_null :robo_requests, :parent_id, false
    change_column_null :robo_requests, :parent_type, false

    remove_reference :robo_requests, :robo_job, index: true, foreign_key: true
  end
end
