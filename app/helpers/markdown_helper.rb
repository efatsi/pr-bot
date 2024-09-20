module MarkdownHelper
  class TextBlock
    attr_accessor :text, :language
    attr_reader :type
    def initialize(text="", type=:text, language=nil)
      @text = text
      @type = type
      @language = language
    end
  end

  def markdown_to_blocks(source_text)
    return [] if source_text.blank?

    blocks = []
    current_block = nil

    source_text.split("\n").each do |line|
      if line.strip.start_with?("```")
        if current_block&.type == :code
          # finishing existing code block
          blocks << current_block
          current_block = nil

        else
          # starting new code block
          # add existing block if exists
          blocks << current_block if current_block.present?

          # make new code block
          language = line.strip[3..-1]
          current_block = TextBlock.new("", :code, language)
        end

      else
        if current_block.nil?
          # starting new text block
          current_block = TextBlock.new(line)
        else
          # adding to current block (text or code)
          current_block.text += "#{line}\n"
        end

      end
    end

    blocks << current_block if current_block

    blocks
  end

  def markdown_to_html(source_text)
    # remove trailing newline
    # replace double newlines with a newline and a non-breaking space
    cleaned_text = source_text.gsub(/\n\z/, "").gsub("\n\n", "\n&nbsp;\n")

    # escape html tags
    cleaned_text.gsub!(/</, "&lt;")
    cleaned_text.gsub!(/>/, "&gt;")

    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    html_content = Markdown.new(cleaned_text, *options).to_html

    html_content = replace_tags_with_dropdowns(html_content)
    html_content.html_safe
  end

  def replace_tags_with_dropdowns(input)
    # look for escaped html tags, replace w/ dropdowns
    input.gsub(/&lt;(\w+)&gt;(.*?)^&lt;\/\1&gt;/m) do
      tag = $1
      content = $2.strip
      "<details><summary>&lt;#{tag}&gt;</summary>#{content}</details>"
    end
  end
end
