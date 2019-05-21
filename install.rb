#!/usr/bin/env ruby

require "pp"
require "optparse"

def msg(fmt, *a, **kw)
  str = (if (a.empty? && kw.empty?) then fmt else sprintf(fmt, *a, **kw) end)
  $stderr.printf("%s\n", str)
end

def inst(filepath, destpath, aslink, force)
    # make sure we're not accidently unlinking an existing rcfile
    if File.symlink?(destpath) then
      msg("path %p is a symlink, will be overwritten", destpath)
      File.unlink(destpath)
    elsif File.file?(destpath) then
      msg("destination %p already exists, but it's not a symlink!", destpath)
      if force then
        msg("deleting %p ...", destpath)
        File.delete(destpath)
      else
        msg("refusing to continue -- fix this first before running this script again")
        exit(1)
      end
    end
    if aslink then
      # then, just symlink it
      msg("symlink(%p, %p)", filepath, destpath)
      File.symlink(filepath, destpath)
    else
      msg("copy(%p, %p)", filepath, destpath)
      File.write(destpath, File.read(filepath))
    end
end

begin
  # self explanatory
  homedir = ENV["HOME"]

  # regex to match file extension(s) for some files
  fextpattern = /\.(sh|rb|pl|ya?ml|cfg|txt)$/
  force = false
  aslink = true
  OptionParser.new{|prs|
    prs.on("-c", "--copy", "copy files instead of using symbolic links"){
      aslink = false
    }
    prs.on("-f", "--force", "force overwrite of existing files (possibly dangerous!)"){
      force = true
    }
  }.parse!
  Dir.glob(File.join(__dir__, "files/_*")).each do |filepath|
    basename = File.basename(filepath)
    # replace underscore with a dot
    destname = basename.gsub(/(^_)/, ".")
    # remove file extension from some files
    if m = destname.match(fextpattern) then
      destname = destname.gsub(fextpattern, "")
    end
    # make absolute path for the destination
    destpath = File.join(homedir, destname)
    inst(filepath, destpath, aslink, force)
  end
end
