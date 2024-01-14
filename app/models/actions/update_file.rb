module Actions
  class UpdateFile < Action

    def self.template
      {
        name: "update_file",
        description: "Update existing file",
        arguments_schema: [
          {name: "file", plan_argument: true},
          {name: "original_content"},
          {name: "new_content"}
        ]
      }
    end

    def fire
      text = File.read(full_filepath)

      new_file_content = if original_content.blank?
        # throw new content at the end
        text + "\n" + new_content

      elsif text.include?(original_content.strip)
        # find and replace
        text.sub(original_content.strip, new_content.strip)

      else
        raise "Original content not found in file"
      end

      File.open(full_filepath, "w") { |f| f.puts new_file_content }
    end

    def unfire
      text = File.read(full_filepath)

      reverted_content = if text.include?(new_content)
        text.gsub(new_content, original_content)
      else
        raise "New content not found in file during rollback"
      end

      File.open(full_filepath, "w") { |f| f.puts reverted_content }
    end

    private

    def original_content
      arguments[:original_content]
    end

    def new_content
      arguments[:new_content]
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
