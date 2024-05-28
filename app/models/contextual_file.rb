class ContextualFile < ApplicationRecord
  belongs_to :robo_job
  belongs_to :robo_event

  has_many :robo_requests, -> { by_id }, as: :parent, dependent: :destroy

  delegate :project, to: :robo_job

  STATUSES = [
    "pending",
    "accepted",
    "ignored"
  ]

  validates :status, presence: true, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end
  scope :not_ignored, -> { where.not(status: "ignored") }

  def file_content
    File.read(project.full_path(filepath))
  end

  def relevance
    robo_analysis.keys.each do |key|
      if robo_analysis[key].key?("relevance")
        return robo_analysis[key]["relevance"]
      end
    end

    return nil
  end

  def relevance_order_key
    if relevance.present?
      inverted_relevance = 6-relevance # since this is 1-5, this will make it 5-1 for sorting
      relevance_key = "#{inverted_relevance}-#{filepath}"

      if accepted?
        return "0-#{relevance_key}"
      else
        return relevance_key
      end
    else
      if accepted?
        return "0-0-#{filepath}"
      else
        # probably ignored
        return "999-#{filepath}"
      end
    end
  end

  def robo_reasoning
    # explanation is set in context-aware examine event, why is set in blind expand event
    ["explanation", "why"].each do |key|
      robo_analysis.keys.each do |robot|
        if robo_analysis[robot].key?(key)
          return robo_analysis[robot][key]
        end
      end
    end

    return nil
  end
end

# == Schema Information
#
# Table name: contextual_files
#
#  id            :bigint           not null, primary key
#  filepath      :string
#  robo_analysis :json
#  status        :string           default("pending")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  robo_event_id :bigint           not null
#  robo_job_id   :bigint           not null
#
# Indexes
#
#  index_contextual_files_on_robo_event_id  (robo_event_id)
#  index_contextual_files_on_robo_job_id    (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_event_id => robo_events.id)
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
