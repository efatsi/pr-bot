class AddRoboJobIdToImageUploads < ActiveRecord::Migration[7.0]
  def change
    add_reference :image_uploads, :robo_job, null: true, foreign_key: true
  end
end
