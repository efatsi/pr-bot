class RoboJob < ApplicationRecord
  belongs_to :project

  has_many :robo_requests, -> { by_id }, as: :parent, dependent: :destroy
  has_many :robo_changes, -> { by_id }, dependent: :destroy

  has_many :followup_jobs, class_name: "RoboJob", foreign_key: :parent_job_id, dependent: :destroy
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

  def all_robo_requests
    if is_parent_job?
      RoboRequest.where(parent_type: "RoboJob", parent_id: [id, *followup_job_ids]).by_id
    else
      robo_requests
    end
  end

  def all_robo_changes
    if is_parent_job?
      RoboChange.where(robo_job_id: [id, *followup_job_ids]).by_id
    else
      robo_changes
    end
  end

  [
    :implementation_overview,
    :additional_notes
  ].each do |field|
    define_method(field) do
      if generated_instructions?
        parsed_instructions[field.to_s]
      end
    end

    define_method("all_#{field.to_s.pluralize}") do
      if is_parent_job?
        [send(field), *followup_jobs.map(&field)].compact
      else
        [send(field)]
      end
    end
  end

  def contextual_file_data
    contextual_files.map do |file|
      {
        name: file,
        content: File.read(full_path(file))
      }
    end
  end

  def parsed_instructions
    @parsed_instructions ||= JSON.parse(generated_instructions)
  end

  def total_cost
    robo_requests.sum(:cost)
  end

  def process_instructions_to_changes
    robo_changes.destroy_all

    parsed_instructions["changes"].each do |changeset|
      robo_changes.create!(
        **changeset,
        raw_json: changeset
      )
    end
  end

  def dig_out_contextual_files(robo_request)
    contextual_files_from_request = robo_request.response.scan(/[\w\-.\/]+/).select do |f|
      full_filepath = full_path(f)

      # Is file, is directory, is not just a dot and/or slash
      File.file?(full_filepath) || File.directory?(full_filepath) &&
        f.gsub(/[\.\/]/, "").length > 0
    end.uniq

    unpack_paths(contextual_files_from_request)
  end

  private

  def is_parent_job?
    parent_job_id.nil?
  end

  def unpack_paths(paths)
    paths.map do |f|
      full_filepath = full_path(f)

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

  def full_path(f)
    File.join(project.filepath, f)
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
