#!/usr/bin/env ruby1.9

require "./getOpts.rb"
require "json"

module Syllable
  attr_accessor(:sounds, :junk, :tone)
  def self.extended(str)
    str.sounds = Array.new
    word = str.upcase

    while (word.length > 0)
      hasToken = false
      Opts.sounds.each do |s|
        l = s.length
        if (word[0...l] == s)
          hasToken = true
          word = word[l..-1]
          if (Opts.sound_table[s]["isInitial"] == true)
            str.sounds << s.upcase
          elsif (Opts.sound_table[s]["isRhyme"] == true)
            str.sounds << s.downcase
          end
          break
        end
      end
      if (word =~ /^[0-9]/)
        str.tone = word[0..-1].to_i
        word = nil
        break
      end
      if (!hasToken)
        str.junk = word
        break
      end
    end
    STDERR.puts ("*** consonant conjunct?: " + str.to_hs.inspect) if (str.sounds.length > 2)
    STDERR.puts ("*** parse failure: " + str.to_hs.inspect) if (str.junk != nil)
    return self
  end


  def to_hs
    return {
      "syllable" => self.upcase,
      "sounds" => @sounds,
      "tone" => @tone,
      "junk" => @junk
    }
  end
end

def parseInitials(fh)
  Opts["initial_table"] = Hash.new
  rowIdx = 0
  while (fh.gets)
    break if (1 > $_.chomp.length)
    rowIdx += 1
    toks = $_.chomp.split(/\t/)
    toks.each_with_index do |t, i|
      colIdx = (i + 1)
      next if (t.length == 0)
      Opts.sound_table[t] = {"row" => rowIdx, "col" => colIdx, "isInitial" => true}
    end
  end
end

def parseRhymes(fh)
  Opts["rhyme_table"] = Hash.new
  rowIdx = 0
  while (fh.gets)
    break if (1 > $_.chomp.length)
    rowIdx += 1
    toks = $_.chomp.split(/\t/)
    toks.each_with_index do |t, i|
      colIdx = (i + 1)
      next if (t.length == 0)
      Opts.sound_table[t] = {"row" => rowIdx, "col" => colIdx, "isRhyme" => true}
    end
  end
end

fh = File::open(Opts.sounds, "r")
Opts["sound_table"] = Hash.new
while (fh.gets)
  if ($_ =~ /^initials:/)
    parseInitials(fh)
  elsif ($_ =~ /^rhymes:/)
    parseRhymes(fh)
  end
  Opts["sounds"] = Opts.sound_table.keys.sort_by{|t| t.length}.reverse
end
fh.close

js = Hash.new
fh = File::open(Opts.charname_list, "r")
while (fh.gets)
  ucs, charName = $_.chomp.split("\t")
  js[ucs] = charName.gsub(/SHUISHU LOGOGRAM /, "").split(/\s+/).collect{|t| t.extend(Syllable).to_hs}
end
fh.close

puts JSON.pretty_generate(js)
