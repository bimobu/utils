# frozen_string_literal: true

require 'debug'

def correct_directory(base_dir)
  Dir.foreach(base_dir) do |filename|
    next if ['.', '..'].include?(filename)

    path = File.join(base_dir, filename)

    if File.directory?(path)
      correct_directory(path)
    else
      correct_file(path)
    end
  end
end

def correct_file(path)
  return unless path.end_with?('.md')

  puts "Correcting #{path}"
  file = File.open(path)
  write_data = correct_file_lines(file).join("\n")
  mtime = file.mtime
  File.write(path, write_data)
  FileUtils.touch path, mtime:
end

def correct_file_lines(file)
  file_lines = file.readlines.map(&:chomp)
  filename = file.path.split('/').last.split('.').first
  file_lines.shift if file_lines.first == "# #{filename}"
  file_lines.shift if file_lines.first == '##'
  file_lines.shift if file_lines.first == ''

  file_lines.map { |line| line.sub(/^\s*\* /, '- [ ] ') }
end

base_dir = 'data'

correct_directory(base_dir)