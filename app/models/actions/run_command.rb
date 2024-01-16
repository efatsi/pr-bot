module Actions
  class RunCommand < Action

    def self.template
      {
        name: "run_command",
        description: "Run a command in the terminal",
        arguments_schema: [
          {name: "command", plan_argument: true},
        ]
      }
    end

    # TODO: fill this out
    def fire
    end

    def unfire
    end

  end
end

# == Schema Information
#
# Table name: actions
#
#  id             :bigint           not null, primary key
#  arguments      :json
#  error          :text
#  history        :json
#  relevant_files :json
#  status         :string           default("pending"), not null
#  summary        :text
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  robo_job_id    :bigint           not null
#
# Indexes
#
#  index_actions_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
