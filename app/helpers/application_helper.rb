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
      if action.in_plan_stage?
        "bg-[#43614dc4]"
      else
        "bg-[#2b4a35]"
      end
    elsif action.action_type == "update_file"
      if action.in_plan_stage?
        "bg-[#6a513cc4]"
      else
        "bg-[#523823]"
      end
    else
      "bg-[#65533e]"
    end
  end
end
