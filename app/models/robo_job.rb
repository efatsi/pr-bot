class RoboJob < ApplicationRecord
  belongs_to :project

  has_many :robo_requests, -> { by_id }, as: :parent, dependent: :destroy
  has_many :actions, -> { by_id }, dependent: :destroy

  has_many :followup_jobs, -> { by_id }, class_name: "RoboJob", foreign_key: :parent_job_id, dependent: :destroy
  belongs_to :parent_job, class_name: "RoboJob", optional: true

  has_many :git_commits, dependent: :destroy

  validates :feature_request, presence: true

  array_field :contextual_files

  scope :parent_jobs, -> { where(parent_job_id: nil) }

  def all_feature_requests
    if is_parent_job?
      [feature_request, *followup_jobs.map(&:feature_request)].compact
    else
      [feature_request]
    end
  end

  def last_contextual_files
    last_job = followup_jobs.last || self
    (last_job.contextual_files + last_job.actions.map(&:file).compact).uniq
  end

  def includes_past_convo?
    include_last_convo? || include_all_convos?
  end

  def implementation_overview
    if generated_instructions?
      generated_instructions["implementation_overview"]
    end
  end

  def total_cost
    robo_requests.sum(:cost)
  end

  def dig_out_contextual_files(robo_request)
    filepaths = JSON.parse(robo_request.response)["files"].map do |f|
      f["filepath"]
    end

    unpack_paths(filepaths)
  end

  def stream_key
    if is_parent_job?
      "robo-job-#{id}-stream"
    else
      parent_job.stream_key
    end
  end

  private

  def unpack_paths(paths)
    paths.map do |f|
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

  def is_parent_job?
    parent_job_id.nil?
  end

  def inspect
    "#<#{self.class}:0x#{object_id.to_s(16)} id: #{id}, feature_request: #{feature_request.truncate(50)}, created_at: #{created_at}, updated_at: #{updated_at}, parent_job_id: #{parent_job_id}, project_id: #{project_id}>"
  end
end

# == Schema Information
#
# Table name: robo_jobs
#
#  id                     :bigint           not null, primary key
#  contextual_files       :string           default([]), is an Array
#  feature_request        :text             not null
#  generated_instructions :json
#  include_all_convos     :boolean          default(FALSE)
#  include_last_convo     :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_job_id          :bigint
#  project_id             :bigint
#
# Indexes
#
#  index_robo_jobs_on_parent_job_id  (parent_job_id)
#  index_robo_jobs_on_project_id     (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_job_id => robo_jobs.id)
#  fk_rails_...  (project_id => projects.id)
#
