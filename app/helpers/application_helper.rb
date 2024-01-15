module ApplicationHelper
  def markdown_to_html(source_text)
    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    Markdown.new(source_text.gsub("\n\n", "\n&nbsp;\n"), *options).to_html.html_safe
  end

  def dropdown_label_bg_for(action)
    if action.skipped?
      nil
    elsif action.failed?
      "bg-[#5f2424]"
    elsif action.action_type == "add_file"
      "bg-[#2b4a35]"
    elsif action.action_type == "update_file"
      "bg-[#523823]"
    else
      "bg-[#65533e]"
    end
  end
end
