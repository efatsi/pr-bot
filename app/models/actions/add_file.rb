module Actions
  class AddFile < Action

    def fire
      save_filename
      FileUtils.mkdir_p(File.dirname(full_filepath))
      File.write(full_filepath, new_content)
    end

    def unfire
      File.delete(full_filepath) if File.exist?(full_filepath)
    end

    private

    def new_content
      arguments[:new_content]
    end

  end
end
