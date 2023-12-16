class Action < ApplicationRecord
  belongs_to :robo_job
  belongs_to :action_template

  def execute
  end

  def revert
  end
end

# == Schema Information
#
# Table name: actions
#
#  id                 :bigint           not null, primary key
#  arguments          :json
#  history            :json
#  status             :string           default("pending"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  action_template_id :bigint           not null
#  robo_job_id        :bigint           not null
#
# Indexes
#
#  index_actions_on_action_template_id  (action_template_id)
#  index_actions_on_robo_job_id         (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (action_template_id => action_templates.id)
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
