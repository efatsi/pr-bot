class RenameRoboRequestTypes < ActiveRecord::Migration[7.0]
  def change
    RoboRequest.where(request_type: "contextual_files").update_all(request_type: "enhance_contextual_files")
    RoboRequest.where(request_type: "instructions").update_all(request_type: "build_instructions")
  end
end
