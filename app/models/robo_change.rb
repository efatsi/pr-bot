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
  validates :original_content, presence: true, if: -> { action == "update_file" }
  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    define_method("#{status}?") do
      self.status == status
    end
  end

  def fire!
    if action == "add_file"
      FileUtils.mkdir_p(File.dirname(file))
      File.write(file, new_content)

    elsif action == "update_file"
      text = File.read(file)

      if !text.include?(original_content)
        raise "Original content not found in file"
      end

      new_file_content = text.gsub(original_content, new_content)
      File.open(file, "w") { |file| file.puts new_file_content }

    else
      raise "Unknown action: #{action}"
    end

    # if all went well, set executed status
    update(status: "executed")

  rescue => e
    # if something failed, set status and error
    update(status: "failed", error: e.message)
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
