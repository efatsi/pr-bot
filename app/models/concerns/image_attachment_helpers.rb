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
      rails_blob_path(image, host: "http://localhost:3069")
    end
  end
end
