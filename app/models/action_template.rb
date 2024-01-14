class ActionTemplate < ApplicationRecord
  belongs_to :project, optional: true
  has_many :actions

  validates :name, presence: true
  validates :command, :reverse_command, :argument_schema, presence: true, if: :user_defined_action?

  scope :system_templates, -> { where(system_action: true) }

  def plan_arguments
    arguments_schema.select do |arg_schema|
      arg_schema[:plan_argument]
    end.map do |arg_schema|
      arg_schema[:name]
    end
  end

  def arguments_schema
    super.map(&:with_indifferent_access)
  end

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
