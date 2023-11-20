module ApplicationHelper
  def markdown_to_html(source_text)
    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    Markdown.new(source_text.gsub("\n\n", "\n&nbsp;\n"), *options).to_html.html_safe
  end

  def dropdown_label_bg_for(robo_change)
    if robo_change.skipped?
      nil
    elsif robo_change.failed?
      "bg-[#5f2424]"
    elsif robo_change.action == "add_file"
      "bg-[#2b4a35]"
    elsif robo_change.action == "update_file"
      "bg-[#523823]"
    else
      "bg-[#65533e]"
    end
  end

  def strip_starting_phrases(text, phrases)
    phrases.each do |phrase|
      new_text = text.sub(/^\s*#{phrase}/, '')

      # if new text is differetn and phrase ends with ', '
      if new_text != text && phrase =~ /, $/
        new_text[0] = new_text[0].upcase
      end

      text = new_text
    end
    text
  end
end
