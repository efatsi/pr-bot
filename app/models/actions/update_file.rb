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
      new_content = new_file_content

      File.open(full_filepath, "w") { |f| f.puts new_content }
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

    def new_file_content
      text = File.read(full_filepath)

      if original_content.blank?
        # throw new content at the end
        return text + "\n" + new_content
      end

      if text.include?(original_content)
        # get index of original content in the file
        index = text.index(original_content)
        # figure out how many newlines are before the original content
        newlines_before = text[0...index].count("\n")
        first_line = text.split("\n")[newlines_before]

        # determine how many spaces are at the beginning of the line containing the original content
        text_indentation = first_line.match(/^\s*/)[0].size
        original_content_indentation = original_content.match(/^\s*/)[0].size
        indentation_difference = text_indentation - original_content_indentation

        # indent the new content to match the original content
        indented_new_content = new_content.split("\n").each_with_index.map do |line, i|
          if i == 0
            # don't indent the first line
            line
          else
            " " * indentation_difference + line
          end
        end.join("\n")

        # simple find and replace
        return text.sub(original_content, indented_new_content)

      elsif text.include?(original_content.gsub("'", "\""))
        # then try with quotations swapped
        return text.sub(original_content.gsub("'", "\""), new_content.gsub("'", "\""))
      end

      # last effort, check if the original content is there but indented
      matched_indentation_amounts(text).each do |indentation|
        pad_line = lambda do |line|
          if line.present?
            " " * indentation + line
          else
            line
          end
        end

        indented_original_content = original_content.strip.split("\n").map(&pad_line).join("\n")
        indented_new_content = new_content.strip.split("\n").map(&pad_line).join("\n")

        if text.include?(indented_original_content)
          return text.sub(indented_original_content, indented_new_content)
        elsif text.include?(indented_original_content.gsub("'", "\""))
          return text.sub(indented_original_content.gsub("'", "\""), indented_new_content.gsub("'", "\""))
        end
      end

      # made it down here, couldn't find a match
      raise "Original content not found in file"
    end

    def original_content
      arguments[:original_content]
    end

    def new_content
      arguments[:new_content]
    end

    def matched_indentation_amounts(text)
      first_line = original_content.strip.split("\n").first

      indentation_amounts = []

      text.lines.each do |line|
        if line.strip == first_line
          line_indentation = line.match(/^\s*/)[0].size
          indentation_amounts << line_indentation
        end
      end

      indentation_amounts.uniq
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
