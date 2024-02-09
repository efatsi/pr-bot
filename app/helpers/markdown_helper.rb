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
    blocks = []
    current_block = nil

    source_text.split("\n").each do |line|
      if line.start_with?("```")
        if current_block&.type == :code
          # finishing existing code block
          blocks << current_block
          current_block = nil

        else
          # starting new code block
          # add existing block if exists
          blocks << current_block if current_block.present?

          # make new code block
          language = line[3..-1]
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

    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    Markdown.new(cleaned_text, *options).to_html.html_safe
  end
end
