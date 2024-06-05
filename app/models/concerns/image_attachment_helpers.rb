module ImageAttachmentHelpers
  def image_path(image)
    if image.present?
      ActiveStorage::Blob.service.path_for(image.key)
    end
  end

  def image_content_type(image)
    if image.present?
      image.content_type
    end
  end

  def image_url(image)
    if image.present?
      rails_blob_path(image, host: "http://localhost:#{ENV.fetch('RAILS_PORT', 3000)}")
    end
  end
end
