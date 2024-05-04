module JobRunners::ExpandContextualFiles
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def handle_response
      # TODO: create related ContextualFile records instead
      # robo_job.update(contextual_files: dig_out_contextual_files(robo_request))
    end

    # extra private

    def dig_out_contextual_files(robo_request)
      filepaths = JSON.parse(robo_request.response)["files"].map do |f|
        f["filepath"]
      end

      unpack_paths(filepaths)
    end

    def unpack_paths(filepaths)
      filepaths.map do |f|
        full_filepath = project.full_path(f)

        if File.file?(full_filepath)
          f
        elsif File.directory?(full_filepath)
          glob_path = File.join(full_filepath, "*")
          subpaths = Dir.glob(glob_path).map do |subpath|
            subpath.gsub(project.filepath, "")
          end
          unpack_paths(subpaths)
        end
      end.flatten.uniq
    end

  end
end
