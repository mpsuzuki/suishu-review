#!/usr/bin/env ruby1.9
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require "json"
require "./getOpts.rb"
require "./parseSoundTable.rb"

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

fh = File::open(Opts.sounds, "r")
parseSoundTable(fh)
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

if (Opts.n4696_attr_tsv)
  name2ucs = Hash.new
  js.each do |ucs, syllables|
    next if (ucs !~ /^U\+1B/)
    # s = syllables.collect{|s| s["syllable"]}.compact.join(" ")
    s = syllables.collect{|s| s["syllable"]}.compact.join("")
    s += syllables.last["glyph_suffix"] if (syllables.last["glyph_suffix"])
    name2ucs[s] = Array.new if (name2ucs[s] == nil)
    name2ucs[s] << ucs
  end

  js["_n4696_attr"] = Hash.new
  fh = File::open(Opts.n4696_attr_tsv, "r")
  keys = fh.gets.chomp.split("\t").collect{|tok| tok.gsub(/^\s*#\s*/, "")}
  while (fh.gets)
    hs = Hash.new
    $_.chomp.split("\t").each_with_index do |v, i|
      hs[ keys[i] ] = v
    end
    py = hs["PDAM22_pinyin"]
    hs.delete("PDAM22_pinyin")
    if (name2ucs.include?(py))
      name2ucs[py].each do |ucs|
        js["_n4696_attr"][ucs] = hs
      end
    end
  end
  fh.close
end

puts JSON.pretty_generate(js)
