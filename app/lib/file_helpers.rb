MAPPING = {
  '\"' => '"',
  "\u003c" => "<",
  "\u003e" => ">",
  "&nbsp;" => "",
}

def clean_text(text)
  MAPPING.each do |og_text, new_text|
    text = text.gsub(og_text, new_text)
  end
  text
end

def add_file(filepath, text)
  FileUtils.mkdir_p(File.dirname(filepath))
  File.write(filepath, clean_text(text))
end

def change_file(filepath, og_text, new_text)
  text = File.read(filepath)
  new_file_content = text.gsub(clean_text(og_text), clean_text(new_text))
  File.open(filepath, "w") { |file| file.puts new_file_content }
end
