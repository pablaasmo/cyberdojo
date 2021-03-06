
require 'Files'
require 'Uuid'

class Sandbox
  attr_accessor :test_timeout
  
  def initialize(root_dir)
    @root_dir, @name = root_dir, Uuid.gen
  end
     
  def dir
    @root_dir + '/sandboxes/' + @name
  end
    
  def name
    @name
  end
  
  def make_dir
    if !File.exists? dir
      Dir.mkdir dir        
    end
  end
  
  def run(language, visible_files)
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # visible_files  are the code/test files from the browser
    # language       the language object (associated with
    #                the visible_files), which may provide hidden_files
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    make_dir
    output = inner_run(language, visible_files)
    system("rm -rf #{dir}")
    output
  end
  
  def inner_run(language, visible_files)
    visible_files.each do |filename,content|
      save_file(filename, content)
    end
    link_files(language.dir, language.support_filenames)
    link_files(language.dir, language.hidden_filenames)
    command  = "cd '#{dir}';" +
               "./cyberdojo.sh"
    max_run_tests_duration = (test_timeout || 10)
    Files::popen_read(command, max_run_tests_duration)
  end
  
  def save_file(filename, content)
    path = dir + '/' + filename
    # No need to lock when writing these files.
    # They are write-once-only
    File.open(path, 'w') do |fd|
      fd.write(makefile_filter(filename, content))
    end
    # .sh files (eg cyberdojo.sh) need execute permissions
    File.chmod(0755, path) if filename =~ /\.sh/    
  end

private

  def link_files(link_dir, link_filenames)
    link_filenames.each do |filename|
      system("ln '#{link_dir}/#{filename}' '#{dir}/#{filename}'")
    end    
  end
  
  def makefile_filter(name, content)
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    
    # makefiles are tab sensitive...
    # The CyberDojo editor intercepts tab keys and replaces them with spaces.
    # Hence this special filter, just for makefiles to convert leading spaces 
    # back to a tab character.
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    
    if name.downcase == 'makefile'
      lines = [ ]
      newline = Regexp.new('[\r]?[\n]')
      content.split(newline).each do |line|
        if stripped = line.lstrip!
          line = "\t" + stripped
        end
        lines.push(line)
      end
      content = lines.join("\n")
    end
    content
  end
  
end
