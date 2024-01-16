module LlmCleaner
  def self.clean_ruby_text(text)
    text.gsub('\\\\(', '#{').gsub('\\\\)', '}')
  end
end
