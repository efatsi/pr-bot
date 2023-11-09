class RoboJob < ApplicationRecord
  has_many :robo_requests, -> { by_id }, dependent: :destroy
  has_many :robo_changes, -> { by_id }, dependent: :destroy

  belongs_to :project
  validates :feature_request, presence: true

  delegate :filepath, :project_context, to: :project

  array_field :contextual_files

  def prepare_request(type)
    robo_requests.new(request_type: type)
  end

  def parsed_instructions
    @parsed_instructions ||= JSON.parse(generated_instructions)
  end

  def run_request(robo_request)
    robo_request.fire!

    if robo_request.response
      case robo_request.request_type
      when "contextual_files"
        self.update(contextual_files: robo_request.response.scan(/[\w\-.\/]+/).select { |f| File.file?(f) })
      when "instructions"
        self.update(generated_instructions: robo_request.response)
        self.process_instructions_to_changes
      end
    else
      raise "Error: #{robo_request.raw_response}"
    end
  end

  def contextual_file_data
    contextual_files.map do |file|
      {
        name: file,
        content: File.read(File.join(filepath, file))
      }
    end
  end

  private

  def process_instructions_to_changes
    parsed_instructions["changes"].each do |changeset|
      robo_changes.create(
        **changeset,
        raw_json: changeset
      )
    end
  end
end

# == Schema Information
#
# Table name: robo_jobs
#
#  id                     :bigint           not null, primary key
#  contextual_files       :string           default([]), is an Array
#  feature_request        :text             not null
#  generated_instructions :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  project_id             :bigint
#
# Indexes
#
#  index_robo_jobs_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
