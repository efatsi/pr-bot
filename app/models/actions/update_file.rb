module Actions
  class UpdateFile < Action

    def fire
      text = File.read(full_filepath)

      new_file_content = if original_content.blank?
        # throw new content at the end
        text + "\n" + new_content

      elsif text.include?(original_content.strip)
        # find and replace
        text.sub(original_content.strip, new_content.strip)

      else
        raise "Original content not found in file"
      end

      File.open(full_filepath, "w") { |f| f.puts new_file_content }
    end

    def unfire
      text = File.read(full_filepath)

      reverted_content = if text.include?(new_content)
        text.gsub(new_content, original_content)
      else
        raise 'New content not found in file during rollback'
      end

      File.open(full_filepath, "w") { |f| f.puts reverted_content }
    end

    private

    def original_content
      arguments[:original_content]
    end

    def new_content
      arguments[:new_content]
    end

  end
end
