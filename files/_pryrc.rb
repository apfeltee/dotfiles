# -*- ruby -*-

require "pp"
require "ostruct"
require "objspace"
require "benchmark"
require "json"
require "win32ole"
require File.join(ENV["HOME"], "/dev/gems/clipboard/lib/clipboard")

# don't need the pager tbh
Pry.config.pager = false
Pry.config.color = false
# auto_indent messes up conemu for some reason
Pry.config.auto_indent = false


Pry.prompt = [
  proc { |target_self, nest_level, pry|
    inpsize = pry.input_array.size
    prname  = Pry.config.prompt_name
    vwclip  = Pry.view_clip(target_self)
    nesting = ":#{nest_level}" unless nest_level.zero?
    "[#{inpsize}]\001\e[0;32m\002#{prname}\001\e[0m\002(\001\e[0;33m\002#{vwclip}\001\e[0m\002)#{nesting}> "
  },
  proc { |target_self, nest_level, pry|
    inpsize = pry.input_array.size
    prname  = Pry.config.prompt_name
    vwclip  = Pry.view_clip(target_self)
    nesting = ":#{nest_level}" unless nest_level.zero?
    "[#{inpsize}]\001\e[1;32m\002#{prname}\001\e[0m\002(\001\e[1;33m\002#{vwclip}\001\e[0m\002)#{nesting}* "
  }
]

###################
## global vars ####
###################
$clip = $clipboard = Clipboard::Unix.new

###################
## awesome_print ##
###################

# make awesome_print available for pry.

require "awesome_print"
AwesomePrint.defaults = {
  index:  false,
  indent: -4,
}
AwesomePrint.pry!


##################
## linguistics ###
##################


require "linguistics"

class Numeric
  # print the word of a number.
  # i.e., 1000 => "one thousand", etc
  def name
    return self.en.numwords
  end
end


##################################
## utility functions/extensions ##
##################################


class Object
  # merely applies JSON.dump on the current class
  def _json_dump
    JSON.dump(self)
  end

  # sends whatever to the clipboard
  def to_clipboard
    stringified = self.pretty_inspect.strip
    printable = (
      if stringified.length > 80 then
        stringified.slice(0, 80) + '...'
      else
        stringified
      end
    ).inspect
    $clipboard.write(stringified)
    $stderr.puts("to_clipboard: wrote #{printable} to clipboard")
    return nil
  end
end

# udump is like dump, but without added quotes
class String
  def udump
    self.dump[1 .. -2]
  end
end


console = Module.new do |mod|
  # instantiate an OLE object.
  # obviously, this will not work on anything else than windows.
  def mod.olenew(progid)
    return WIN32OLE.new(progid)
  end

  # login to reddit using environment variables.
  # probably not very useful for most users.
  def mod.reddit_login
    return Redd.it(
      client_id: ENV["REDDPICS_APPID"],
      secret: ENV["REDDPICS_APIKEY"],
      username: ENV["REDDPICS_USERNAME"],
      password: ENV["REDDPICS_PASSWORD"],
      user_agent: "ImageDownloader (ver1.0)"
    )
  end


  # retrieve path(s) of a module.
  # if a module is, for some reason, installed/available in more than
  # one place in $LOAD_PATH, an array is returned. otherwise, a string
  # is returned.
  def mod.findmodpath(name)
    # in case we found multiple results ...
    results = []
    $LOAD_PATH.each do |path|
      dirpath = File.join(path, name)
      rbpath = (dirpath + ".rb")
      # might just be a directory
      if File.directory?(dirpath) then
        results << dirpath
      elsif File.file?(rbpath) then
        results << rbpath
      end
    end
    if results.length > 0 then
      if results.length > 1 then
        return results
      end
      return results.first
    end
    return nil
  end

  # just a dumb shortcut.
  def mod.benchmeasure(&block)
    return Benchmark.measure do
      block.call
    end
  end

  # dumps all global objects to $path.
  # warning: will create a ***VERY*** large file!
  def mod.dump_global_objects_to_file(path)
    count = 0
    begin
      File.open(path, "w") do |fh|
        ObjectSpace.each_object do |o|
          begin
            fh << o.to_s.dump
            count += 1
          rescue => err
            $stderr.puts("dump_global_objects_to_file: #{err.class}: #{err.message}")
          end
        end
      end
    rescue => err
      $stderr.puts("failed to write to #{path.dump}: #{err}")
    ensure
      $stderr.puts("wrote #{count} object(s) to #{path.dump}")
    end
  end

  # retrieve all methods of a class.
  # if $source is true, include source code string (if available)
  def mod.allmethods(klass, source: false)
    ret = {}
    funcs = %i(method instance_method)
    funcs.each do |func|
      # turns, for example, "instance_method" into :instance_methods
      getterfunc = (func.to_s + "s").to_sym
      # "call" $getterfunc, except those inherited from Object 
      (klass.send(getterfunc) - Object.send(getterfunc)).each do |m|
        # call $func (#method or #instance_method) to retrieve a Method instance...
        meth = klass.send(func, m)
        # populate the thing ...
        struc = OpenStruct.new(
          name: m,
          hash: meth.hash,
          source_location: meth.source_location,
          to_s: meth.to_s,
        )
        # and, if the method was defined in ruby, get the source too
        if meth.respond_to?(:source) && source then
          begin
            struc.source = meth.source
          rescue MethodSource::SourceNotFoundError
            struc.source = nil
          end
        end
        # do the thing
        ret[m] = struc
      end
    end
    # all done.
    return ret
  end

  # like allmethods, but only include methods written in ruby 
  def mod.srcmethods(klass, source: false)
    ret = {}
    return allmethods(klass, source: source).select do |name, method|
      not method.source_location.nil?
    end
  end

  # like srcmethods, but get source struct of a specific function
  # in typical Hash fashion, will return nil if $name doesn't exist
  def mod.srcmethod(klass, name, source: false)
    return srcmethods(klass, source: source)[name]
  end
end
