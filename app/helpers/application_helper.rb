module ApplicationHelper
  def action_dropdown_label_bg(action)
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

  def contextual_file_dropdown_label_bg(contextual_file)
    if contextual_file.tabled? || contextual_file.ignored?
      "bg-gray-700"
    else
      "bg-[#263141]"
    end
  end
end
