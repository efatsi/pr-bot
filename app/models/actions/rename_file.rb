module Actions
  class RenameFile < Action

    def self.template
      {
        name: "rename_file",
        description: "Rename file or directory",
        arguments_schema: [
          {name: "file", plan_argument: true},
          {name: "new_file", plan_argument: true}
        ]
      }
    end

    def fire
      save_filename
      new_full_filepath = File.join(robo_job.project.filepath, new_file)

      if File.exist?(full_filepath) || Dir.exist?(full_filepath)
        FileUtils.mv(full_filepath, new_full_filepath)
      else
        raise "File or directory to be renamed does not exist"
      end
    end

    def unfire
      new_full_filepath = File.join(robo_job.project.filepath, new_file)
      if File.exist?(new_full_filepath) || Dir.exist?(new_full_filepath)
        FileUtils.mv(new_full_filepath, full_filepath)
      else
        raise "File or directory to be renamed does not exist"
      end
    end

    private

    def new_file
      arguments[:new_file]
    end

  end
end

# == Schema Information
#
# Table name: actions
#
#  id              :bigint           not null, primary key
#  arguments       :json
#  error           :text
#  history         :json
#  status          :string           default("pending"), not null
#  summary         :text
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  robo_request_id :bigint
#
# Indexes
#
#  index_actions_on_robo_request_id  (robo_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_request_id => robo_requests.id)
#
