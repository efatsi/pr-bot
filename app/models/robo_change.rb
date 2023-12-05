class RoboChange < ApplicationRecord
  VALID_ACTIONS = [
    "add_file",
    "update_file",
    "rename_file",
    "remove_file"
  ]

  STATUSES = [
    "pending",
    "executed",
    "failed",
    "skipped"
  ]

  belongs_to :robo_job

  validates :raw_json, :file, presence: true
  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end

  def fire!
    if action == "add_file"
      save_filename
      FileUtils.mkdir_p(File.dirname(full_filepath))
      File.write(full_filepath, new_content)

    elsif action == "update_file"
      text = File.read(full_filepath)

      if !text.include?(original_content.strip)
        raise "Original content not found in file"
      end

      new_file_content = text.gsub(original_content.strip, new_content.strip)
      File.open(full_filepath, "w") { |f| f.puts new_file_content }

    elsif action == "rename_file"
      save_filename
      new_full_filepath = File.join(robo_job.project.filepath, new_file)

      if File.exist?(full_filepath) || Dir.exist?(full_filepath)
        FileUtils.mv(full_filepath, new_full_filepath)
      else
        raise 'File or directory to be renamed does not exist'
      end
    else
      raise "Unknown action: #{action}"
    end

    # if all went well, set executed status
    update(status: "executed")

  rescue => e
    # if something failed, set status and error
    update(status: "failed", error: e.message)
  end

  def unfire!
    raise 'Only executed changes can be rolled back' unless executed?

    if action == "add_file"
      File.delete(full_filepath) if File.exist?(full_filepath)
    elsif action == "update_file"
      text = File.read(full_filepath)
      if text.include?(new_content)
        reverted_content = text.gsub(new_content, original_content)
        File.open(full_filepath, "w") { |f| f.puts reverted_content }
      else
        raise 'New content not found in file during rollback'
      end
    elsif action == "rename_file"
      new_full_filepath = File.join(robo_job.project.filepath, new_file)
      if File.exist?(new_full_filepath) || Dir.exist?(new_full_filepath)
        FileUtils.mv(new_full_filepath, full_filepath)
      else
        raise 'File or directory to be renamed does not exist'
      end
    else
      raise "Unknown action: #{action}"
    end

    update(status: "pending")
  rescue => e
    update(status: "failed", error: e.message)
  end

  def unskip!
    raise 'Only skipped changes can be un-skipped' unless skipped?

    update(status: 'pending')
  rescue => e
    update(status: 'failed', error: e.message)
  end

  def full_filepath
    if file.downcase.start_with?(robo_job.project.filepath.downcase)
      file
    else
      File.join(robo_job.project.filepath.downcase, file)
    end
  end

  def timestamped_file
    if "/[timestamp]_".in?(file.downcase) || "/timestamp_".in?(file.downcase)
      file.gsub(/\[?timestamp\]?/i, Time.now.strftime("%Y%m%d%H%M%S"))
    else
      file
    end
  end

  def save_filename
    # in case timestampe is being swapped out
    update(file: timestamped_file) if timestamped_file != file
  end
end

# == Schema Information
#
# Table name: robo_changes
#
#  id               :bigint           not null, primary key
#  action           :string           not null
#  error            :string
#  file             :string
#  new_content      :text             not null
#  new_file         :string
#  original_content :text
#  raw_json         :json             not null
#  status           :string           default("pending"), not null
#  summary          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  robo_job_id      :bigint           not null
#
# Indexes
#
#  index_robo_changes_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
