#!/usr/bin/env ruby1.9

if (!Object.const_defined?("Opts"))
  Opts = Hash.new
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
      Opts["sound_table"][romanizedValue] = {"row" => rowIdx, "col" => colIdx, "is" + subtableName => true, "ipa" => ipaValue}
    end
  end
end

def parseSoundTable(fh)
  Opts["sound_table"] = Hash.new
  while (fh.gets)
    if ($_ =~ /^initials:/)
      parseSubtable(fh, "Initial")
    elsif ($_ =~ /^rhymes:/)
      parseSubtable(fh, "Rhyme")
    end
    Opts["sounds"] = Opts["sound_table"].keys.sort_by{|t| t.length}.reverse
  end
end
