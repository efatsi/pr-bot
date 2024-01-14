module Actions
  class RemoveFile < Action

    def fire
      if File.exist?(full_filepath)
        text = File.read(full_filepath)
        File.delete(full_filepath)

        self.history << {
          direction: "fire",
          file_text: text,
        }
      end
    end

    def unfire
      if history.present?
        File.write(full_filepath, history.last[:file_text])
      end
    end

  end
end
