#!/usr/bin/env ruby

homedir = ENV["HOME"]
thisdir = File.expand_path File.dirname(__FILE__)
Dir.glob("files/_*").each do |file|
  filename = File.basename(file)
  filepath = File.join(thisdir, file)
  destname = filename.gsub(/(^_)/, ".")
  destpath = File.join(homedir, destname)
  if File.symlink?(destpath) then
    puts "path '#{destpath}' is a symlink, will be overwritten"
    File.unlink(destpath)
  elsif File.file?(destpath) then
    puts "destination '#{destpath}' already exists, but it's not a symlink -- refusing to continue!"
    puts "fix this first before running this script again"
  end
  puts "symlink(#{filepath.inspect}, #{destpath.inspect})"
  File.symlink(filepath, destpath)
end
