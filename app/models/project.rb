class Project < ApplicationRecord
  has_many :robo_jobs

  validates :filepath, :project_context, presence: true

  def to_s
    filepath
  end
end

# == Schema Information
#
# Table name: projects
#
#  id              :bigint           not null, primary key
#  filepath        :string           not null
#  project_context :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
