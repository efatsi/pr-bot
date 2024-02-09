class Action < ApplicationRecord
  include FileHelpers

  belongs_to :robo_job
  has_many :robo_requests, as: :parent, dependent: :destroy

  STATUSES = [
    "pending",   # ready to be executed
    "executed",  # has been executed
    "failed",    # failed to execute/revert
    "skipped"    # was skipped by user
  ]

  validates :status, presence: true, inclusion: { in: STATUSES }

  delegate :project, to: :robo_job

  def self.action_templates
    [
      Actions::AddFile.template,
      Actions::UpdateFile.template,
      Actions::RenameFile.template,
      Actions::RemoveFile.template,
      # Actions::RunCommand.template
    ]
  end

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end

  def action_type
    self.class.name.demodulize.underscore
  end

  def fire!
    # this is defined in subclasses
    fire

    # if all went well, set executed status
    update(status: "executed")

  rescue => e
    # if something failed, set status and error
    update(status: "failed", error: e.message)
  end

  def unfire!
    # this is defined in subclasses
    unfire

    # reset status back to pending
    update(status: "pending")

  rescue => e
    update(status: "failed", error: e.message)
  end

  def arguments
    super.with_indifferent_access
  end

  # helper methods & getters
  # ...not used
  #
  # def arguments_schema
  #   self.class.template[:arguments_schema]
  # end

  # def history
  #   (super || []).map(&:with_indifferent_access)
  # end

  def inspect
    "#<#{self.class}:0x#{object_id.to_s(16)} id: #{id}, status: #{status}, created_at: #{created_at}, updated_at: #{updated_at}>"
  end
end

# == Schema Information
#
# Table name: actions
#
#  id          :bigint           not null, primary key
#  arguments   :json
#  error       :text
#  history     :json
#  status      :string           default("pending"), not null
#  summary     :text
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  robo_job_id :bigint           not null
#
# Indexes
#
#  index_actions_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
