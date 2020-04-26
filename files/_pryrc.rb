# -*- ruby -*-

$VERBOSE = true

require "pp"
require "ostruct"
require "objspace"
require "benchmark"
require "json"
require "win32ole"
require "uri"
require "cgi"
require "base64"
require File.join(ENV["HOME"], "/dev/gems/lib/clipboard")
require File.join(ENV["HOME"], "dev/gems/lib/repr")

# don't need the pager tbh
Pry.config.pager = false
Pry.config.color = true
# auto_indent messes up conemu for some reason
Pry.config.auto_indent = false


#Pry.config.prompt = [
#  proc { "input> " },
#  proc { "     | " }
#]


=begin
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
=end

#################################
## global vars and functions ####
#################################
$clip = $clipboard = Clipboard::Unix.new

module Tools
  def self.verbose_require(mod)
    $stderr.printf("requiring %p ...\n", mod)
    Kernel.require(mod)
  end
end

# allows "piping" to some sort of I/O receiver
class Object

  def _eachdo(method, cacheinit, mtargs, parentblock, dosplat, &b)
    cache = cacheinit.dup
    mtargs.each do |arg|
      rt = (
        if dosplat then
          self.send(method, *arg)
        else
          self.send(method, arg)
        end
      )
      if cache.is_a?(Hash) then
        cache[arg] = rt
      else
        cache.push(rt)
      end
    end
    return cache
  end

  def _write_to(dest)
    rt = 0
    if dest.is_a?(IO) || dest.respond_to?(:write) then
      rt = dest.write(self.to_s)
    else
      # lets you do stuff like:
      #
      #   somefunc("blah") | :somefunc [| ...]
      #
      # where the symbol corresponds to a function taking a single argument
      # 
      if dest.is_a?(Symbol) then
        begin
          mt = Kernel.method(dest)
          return mt.call(self)
        rescue => ex
          raise NoMethodError, sprintf("Object#_write_to: no method named %p", dest)
        end
      end
      raise ArgumentError, sprintf("Object#_write_to: destination class %p is not IO, and does not respond to #write", dest.class)
    end
    return rt
  end
end

class String
  def |(dest)
    self._write_to(dest)
  end

  def base64
    return Base64.encode64(self).strip
  end

  def xor(n)
    tmp = []
    self.each_byte do |b|
      tmp.push((b ^ n).chr)
    end
    return tmp.join
  end



  def exor(*vals, &b)
    return self._eachdo(:xor, {}, vals, b, false)
  end

  alias_method(:b64, :base64)
end

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


class Numeric
  # print the word of a number.
  # i.e., 1000 => "one thousand", etc
  def to_words(lang="en")
    require "linguistics" unless defined?(Linguistics)
    enlang = Linguistics.load_language(lang)
    words = enlang::Numbers.number_to_standard_word_groups(self.to_i)
    return words
  end

  def to_name(j=" ")
    return to_words.join(j)
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
    #prettified = self.pretty_inspect.strip
    prettified = self.to_s
    stringified = self.to_s
    printable = (
      if prettified.length > 80 then
        prettified.slice(0, 80) + '...'
      else
        prettified
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

  # retrieve all methods of a class.
  # if $source is true, include source code string (if available)
  def mod.allmethods(klass, source: false)
    ret = {}
    funcs = %i(method instance_method)
    klass = klass.class if !klass.is_a?(Class)
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

### custom commands ###
=begin
custom_command_set = Pry::CommandSet.new do
  command("copy", "Copy argument to the clip-board") do |str|
    IO.popen('pbcopy', 'w') do |f|
      f << str.to_s
    end
  end
end

Pry.config.commands.import(custom_command_set)
=end


