#!/usr/bin/env ruby

require "pp"
require "optparse"

SPECIAL = {
  "_jq.jq" => ".jq",
}


# regex to match file extension(s) for some files
FEXTPATTERN = /\.(sh|rb|pl|ya?ml|cfg|txt)$/


def msg(fmt, *a, **kw)
  str = (if (a.empty? && kw.empty?) then fmt else sprintf(fmt, *a, **kw) end)
  $stderr.printf("%s\n", str)
end

def inst(filepath, destpath, aslink, force)
  #msg("filepath=%p, destpath=%p", filepath, destpath); return
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

#glob_and_build("keep-ext/_*", false) do |fpath, destpath|

def glob_and_build(glpat, keepext, &b)
  homedir = ENV["HOME"]
  Dir.glob(File.join(__dir__, glpat)) do |path|
    fpath = File.absolute_path(path)
    basename = File.basename(fpath)
    destname = nil
    if SPECIAL.key?(basename) then
      destname = SPECIAL[basename]
    else
      # replace underscore with a dot
      destname = basename.gsub(/(^_)/, ".")
      # remove file extension from some files
      if not keepext then
        if (m = destname.match(FEXTPATTERN)) != nil then
          destname = destname.gsub(FEXTPATTERN, "")
        end
      end
    end
    # make absolute path for the destination
    destpath = File.join(homedir, destname)
    b.call(fpath, destpath)
  end
end

begin
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
  glob_and_build("files/_*", false) do |fpath, destpath|
    inst(fpath, destpath, aslink, force)
  end
  glob_and_build("keep-ext/_*", true) do |fpath, destpath|
    inst(fpath, destpath, aslink, force)
  end
end
