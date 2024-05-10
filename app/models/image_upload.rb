class ImageUpload < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_one_attached :image

  def attach_local_file(path)
    self.image.attach(io: File.open(path), filename: File.basename(path))
  end

  def image_path
    if self.image.present?
      rails_blob_path(image, host: "http://localhost:3069")
    end
  end
end

# == Schema Information
#
# Table name: image_uploads
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
