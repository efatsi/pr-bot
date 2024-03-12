module FileHelpers

  def file
    arguments[:file]
  end

  def save_filename
    # in case timestampe is being swapped out
    update(file: timestamped_file) if timestamped_file != file
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

    if file.downcase.start_with?(robo_job.project.filepath.downcase)
      file
    else
      File.join(robo_job.project.filepath.downcase, file)
    end
  end

end
