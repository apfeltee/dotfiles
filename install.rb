#!/usr/bin/env ruby

require "pp"

# self explanatory
homedir = ENV["HOME"]

# get full path to this directory
thisdir = File.expand_path(File.dirname(__FILE__))

# regex to match file extension(s) for some files
fextpattern = /\.(sh|rb)$/

Dir.glob("files/_*").each do |file|
  filename = File.basename(file)
  # get absolute path of $file
  filepath = File.join(thisdir, file)
  # replace underscore with a dot
  destname = filename.gsub(/(^_)/, ".")
  # remove file extension from some files
  if m = destname.match(fextpattern) then
    destname = destname.gsub(fextpattern, "")
  end
  # make absolute path for the destination
  destpath = File.join(homedir, destname)
  # make sure we're not accidently unlinking an existing rcfile
  if File.symlink?(destpath) then
    puts "path '#{destpath}' is a symlink, will be overwritten"
    File.unlink(destpath)
  elsif File.file?(destpath) then
    puts "destination '#{destpath}' already exists, but it's not a symlink -- refusing to continue!"
    puts "fix this first before running this script again"
  end
  # then, just symlink it
  puts "symlink(#{filepath.inspect}, #{destpath.inspect})"
  File.symlink(filepath, destpath)
end
