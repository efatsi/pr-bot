module ApplicationHelper
  def markdown_to_html(source_text)
    options = [:hard_wrap, :autolink, :no_intra_emphasis, :fenced_code_blocks]
    Markdown.new(source_text.gsub("\n\n", "\n&nbsp;\n"), *options).to_html.html_safe
  end
end
