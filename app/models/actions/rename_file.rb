module Actions
  class RenameFile < Action

    def fire
      save_filename
      new_full_filepath = File.join(robo_job.project.filepath, new_file)

      if File.exist?(full_filepath) || Dir.exist?(full_filepath)
        FileUtils.mv(full_filepath, new_full_filepath)
      else
        raise 'File or directory to be renamed does not exist'
      end
    end

    def unfire
      new_full_filepath = File.join(robo_job.project.filepath, new_file)
      if File.exist?(new_full_filepath) || Dir.exist?(new_full_filepath)
        FileUtils.mv(new_full_filepath, full_filepath)
      else
        raise 'File or directory to be renamed does not exist'
      end
    end

    private

    def new_file
      arguments[:new_file]
    end

  end
end
