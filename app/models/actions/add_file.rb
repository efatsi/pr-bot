module Actions
  class AddFile < Action

    def self.template
      {
        name: "add_file",
        description: "Add new file",
        arguments_schema: [
          {name: "file", plan_argument: true},
          {name: "new_content"}
        ]
      }
    end

    def fire
      save_filename
      FileUtils.mkdir_p(File.dirname(full_filepath))
      File.write(full_filepath, new_content)
    end

    def unfire
      File.delete(full_filepath) if File.exist?(full_filepath)
    end

    private

    def new_content
      arguments[:new_content]
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
