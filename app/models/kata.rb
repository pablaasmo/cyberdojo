
require 'Files'
require 'make_time_helper.rb'

class Kata
  
  include MakeTimeHelper
  extend MakeTimeHelper
  
  def self.inner_dir(id)
    id[0..1] || ""
  end
  
  def self.outer_dir(id)
    id[2..9] || ""
  end
  
  #TODO ? create_new(root_dir, id, info) (info has everything except id)
  def self.create_new(root_dir, info)    
    katas_root_dir = root_dir + '/katas'
    inner_dir = katas_root_dir + '/' + Kata::inner_dir(info[:id])
    
    if !File.directory? inner_dir
      Dir.mkdir inner_dir
    end
    
    outer_dir = inner_dir + '/' + Kata::outer_dir(info[:id])
    Dir.mkdir outer_dir
    Files::file_write(outer_dir + '/manifest.rb', info)
  end
  
  def self.exists?(root_dir, id)
    inner_dir = root_dir + '/katas/' + Kata::inner_dir(id)
    outer_dir = inner_dir + '/' + Kata::outer_dir(id)
    File.directory? outer_dir
  end

  Index_filename = 'index.rb' 
  
  #---------------------------------

  def initialize(root_dir, id)
    @root_dir,@id = root_dir,id
  end

  def name
    manifest[:name]
  end
  
  def diff
    if manifest[:diff_id]
      Diff.new(manifest)
    else
      nil
    end
  end
  
  def avatar_names
    Avatar.names.select { |name| File.exists? dir + '/' + name }
  end
  
  def avatars
    avatar_names.map { |name| Avatar.new(self, name) }
  end

  def all_increments
    all = { }
    avatars.each do |avatar|
      all[avatar.name] = avatar.increments
    end
    all
  end
  
  def language
    Language.new(@root_dir, manifest[:language])
  end
  
  def exercise
    Exercise.new(@root_dir, manifest[:exercise])
  end

  def visible_files
    # language.visible_files != visible_files
    # this is because kata.visible_files has the
    # instructions and output 'pseudo' files mixed in
    manifest[:visible_files]
  end
      
  def created
    Time.mktime(*manifest[:created])
  end
  
  def age_in_seconds( now = Time.now )
    (now - created).to_i
  end
  
  def dir    
    root_dir + '/katas/' + Kata::inner_dir(id) + '/' + Kata::outer_dir(id)
  end
  
  def id
    @id
  end
  
private

  def root_dir
    @root_dir
  end
  
  def manifest_filename
    dir + '/' + 'manifest.rb'
  end
  
  def manifest
    eval IO.read(manifest_filename)
  end
  
end

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class Diff
  
  def initialize(manifest)
    @manifest = manifest
  end
  
  def id
    @manifest[:diff_id]
  end
  
  def avatar
    @manifest[:diff_avatar]
  end
  
  def tag
    @manifest[:diff_tag]
  end
  
end
