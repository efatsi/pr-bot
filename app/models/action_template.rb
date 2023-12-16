class ActionTemplate < ApplicationRecord
  belongs_to :project, optional: true
  has_many :actions

  validates :name, presence: true
  validates :command, :reverse_command, :argument_schema, presence: true, if: :user_defined_action?

  private

  def user_defined_action?
    !system_action
  end
end

# == Schema Information
#
# Table name: action_templates
#
#  id               :bigint           not null, primary key
#  arguments_schema :json
#  command          :string
#  description      :string
#  name             :string           not null
#  reverse_command  :string
#  system_action    :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_id       :bigint
#
# Indexes
#
#  index_action_templates_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
