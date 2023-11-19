class RoboChange < ApplicationRecord
  VALID_ACTIONS = [
    "add_file",
    "update_file"
  ]

  STATUSES = [
    "pending",
    "executed",
    "failed",
    "skipped"
  ]

  belongs_to :robo_job

  validates :raw_json, :file, :new_content, presence: true
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

      if !text.include?(original_content)
        raise "Original content not found in file"
      end

      new_file_content = text.gsub(original_content, new_content)
      File.open(full_filepath, "w") { |f| f.puts new_file_content }

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
    File.join(robo_job.project.filepath, file)
  end

  def file
    file_from_ai = self[:file]

    if "/[timestamp]_".in?(file_from_ai.downcase) || "/timestamp_".in?(file_from_ai.downcase)
      file_from_ai.gsub(/\[?timestamp\]?/i, Time.now.strftime("%Y%m%d%H%M%S"))
    end
  end

  def save_filename
    # in case timestampe is being swapped out
    update(file: file) if file != self[:file]
  end
end

# == Schema Information
#
# Table name: robo_changes
#
#  id               :bigint           not null, primary key
#  action           :string           not null
#  error            :string
#  file             :string           not null
#  new_content      :text             not null
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
