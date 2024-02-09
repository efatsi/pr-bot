module Actions
  class RemoveFile < Action

    def self.template
      {
        name: "remove_file",
        description: "Remove file",
        arguments_schema: [
          {name: "file", plan_argument: true}
        ]
      }
    end

    def fire
      if File.exist?(full_filepath)
        text = File.read(full_filepath)
        File.delete(full_filepath)

        self.history << {
          direction: "fire",
          file_text: text,
        }
      end
    end

    def unfire
      if history.present?
        File.write(full_filepath, history.last[:file_text])
      end
    end

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
