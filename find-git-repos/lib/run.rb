require 'debug'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('-p', '--postfix POSTFIX', 'The postfix added to each of the git repos') { |o| options[:postfix] = o }
end.parse!

if ARGV.count > 1
  puts "Too many arguments"
end

base_dir = ARGV[0]

def is_git_repo(path)
  File.exist? "#{path}/.git"
end

# As described here: https://stackoverflow.com/questions/9671259/ruby-local-variable-is-undefined
define_method :log_git_repos do |base_dir|
  Dir.foreach(base_dir) do |filename|
    next if ['.', '..'].include?(filename)
  
    path = File.join(base_dir, filename)
  
    if File.directory?(path)
      if is_git_repo(path)
        puts path + options[:postfix]
      else 
        log_git_repos(path)
      end
    end
  end
end

log_git_repos(base_dir)