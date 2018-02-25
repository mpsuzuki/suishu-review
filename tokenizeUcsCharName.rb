#!/usr/bin/env ruby1.9
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require "./getOpts.rb"
require "json"

module Syllable
  attr_accessor(:roman, :junk, :ipa, :tone)
  def self.extended(str)
    str.roman = Array.new
    str.ipa = Array.new
    word = str.upcase

    while (word.length > 0)
      hasToken = false
      Opts.sounds.each do |s|
        props = Opts.sound_table[s]
        l = s.length
        if (word[0...l] == s)
          hasToken = true
          word = word[l..-1]
          if (Opts.sound_table[s]["isInitial"] == true)
            str.roman << s.upcase
            str.ipa << props["ipa"]
          elsif (Opts.sound_table[s]["isRhyme"] == true)
            str.roman << s.downcase
            str.ipa << props["ipa"]
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
    STDERR.puts ("*** consonant conjunct?: " + str.to_hs.delete_if{|k,v| k == "ipa"}.inspect) if (str.roman.length > 2)
    STDERR.puts ("*** parse failure: " + str.to_hs.delete_if{|k,v| k == "ipa"}.inspect) if (str.junk != nil)
    return self
  end


  def to_hs
    return {
      "syllable" => self,
      "roman" => @roman,
      "ipa" => @ipa,
      "tone" => @tone,
      "junk" => @junk
    }
  end
end

def parseSubtable(fh, subtableName)
  rowIdx = 0
  while (fh.gets)
    break if (1 > $_.chomp.length)
    rowIdx += 1
    $_.chomp.split(/\t/).each_with_index do |tok, i|
      if (tok.include?("/"))
        ipaValue, romanizedValue = tok.split("/")
      else
        ipaValue = tok
        romanizedValue = ""
      end
      colIdx = (i + 1)
      next if (romanizedValue.length == 0)
      Opts.sound_table[romanizedValue] = {"row" => rowIdx, "col" => colIdx, "is" + subtableName => true, "ipa" => ipaValue}
    end
  end
end

fh = File::open(Opts.sounds, "r")
Opts["sound_table"] = Hash.new
while (fh.gets)
  if ($_ =~ /^initials:/)
    parseSubtable(fh, "Initial")
  elsif ($_ =~ /^rhymes:/)
    parseSubtable(fh, "Rhyme")
  end
  Opts["sounds"] = Opts.sound_table.keys.sort_by{|t| t.length}.reverse
end
fh.close

js = Hash.new
fh = File::open(Opts.charname_list, "r")
while (fh.gets)
  ucs, charName = $_.chomp.split("\t")
  charNameTokens = charName.gsub(/SHUISHU LOGOGRAM /, "").split(/\s+/)
  glyphSuffix = nil
  if (charNameTokens.last =~ /-[A-Z]$/)
    glyphSuffix = charNameTokens.last[-2..-1]
    charNameTokens[ charNameTokens.length - 1 ] = charNameTokens[ charNameTokens.length - 1 ][0..-3]
  end
  js[ucs] = charNameTokens.collect{|t| t.extend(Syllable).to_hs}
  js[ucs] << { "syllable" => nil, "glyph_suffix" => glyphSuffix } if (glyphSuffix)
end
fh.close
js["_sound_table"] = Opts.sound_table

puts JSON.pretty_generate(js)
