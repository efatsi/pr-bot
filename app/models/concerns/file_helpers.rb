module FileHelpers

  def file
    arguments[:file]
  end

  def save_filename
    # in case 'timestamp' key is being swapped out
    if file != timestamped_file
      updated_arguments = arguments.merge(file: timestamped_file)
      update(arguments: updated_arguments)
    end
  end

  def timestamped_file
    if "/[timestamp]_".in?(file.downcase) || "/timestamp_".in?(file.downcase)
      file.gsub(/\[?timestamp\]?/i, Time.now.strftime("%Y%m%d%H%M%S"))
    else
      file
    end
  end

  def full_filepath
    robo_job = robo_request.robo_job

    if file.downcase.start_with?(robo_job.project.repo_path.downcase)
      file
    else
      File.join(robo_job.project.repo_path.downcase, file)
    end
  end

end
