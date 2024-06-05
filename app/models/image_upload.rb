class ImageUpload < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :robo_job, optional: true

  has_one_attached :image

  def image_path
    if self.image.present?
      ActiveStorage::Blob.service.path_for(image.key)
    end
  end

  def image_content_type
    if self.image.present?
      image.content_type
    end
  end

  def image_url
    if self.image.present?
      rails_blob_path(image, host: "http://localhost:#{ENV.fetch('RAILS_PORT', 3000)}")
    end
  end

  # dev utility
  def attach_local_file(path)
    self.image.attach(io: File.open(path), filename: File.basename(path))
  end
end

# == Schema Information
#
# Table name: image_uploads
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  robo_job_id :bigint
#
# Indexes
#
#  index_image_uploads_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
