#!/usr/bin/env ruby1.9
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"


Opts = {
  "args" => [],
  "style_for_column" => {
    "NewNumber" => { "font" => ["Times<20>New<20>Roman,Bold"], "fontSize" => 9 },
    "Ipa" => { "font" => ["Doulos<20>SIL"], "fontSize" => 9 },
    "Pinyin" => { "font" => ["Doulos<20>SIL"], "fontSize" => 9 },
    "Origin" => { "font" => ["Doulos<20>SIL"], "fontSize" => 9 },
    "Meaning" => { "font" => ["SimSun", "Arial<20>Unicode<20>MS"], "fontSize" => 9 }
  },
  :"do-not-auto-extend-to-array" => true
}

require "./getOpts.rb"
require "./libRect.rb"
require "./xString.rb"

require "json"

Opts["check-pages"] = Opts.check_pages.split(",").collect{|t|
  if (t.class == String)
    arr = Array.new
    t.split(",").each do |t2|
      if (t2.include?("-"))
        vs = t2.split("-")
        arr << ((vs.first.to_i)..(vs.last.to_i)).to_a
      else
        arr << t2.to_i
      end
    end
    arr.flatten
  else
    t.to_i
  end
}.flatten

class Hash
  def page; return self["page"]; end
  def base; return self["base"]; end
  def font; return self["font"]; end
  def fontSize; return self["fontSize"]; end
  def rot; return self["rot"]; end
  def s; return self["s"]; end

  def cell; return self["cell"]; end
  def newNumber; return self["newNumber"]; end

  def testFontFamilyAndSize(clm)
    r = true
    r = false if (!Opts.style_for_column[clm]["font"].include?( self.font.split("+").last ))
    r = false if (self.fontSize != Opts.style_for_column[clm]["fontSize"])
    return r
  end

  def isNewNumber
    return false if (!self.testFontFamilyAndSize("NewNumber"))
    return false if (self.s !~ /^[0-9]+\s*$/)
    return true
  end

  def isPinyin
    return false if (!self.testFontFamilyAndSize("Pinyin"))
    return false if (self.s =~ /^S[0-9]+\s*$/) # exclude "Origin" column syntax
    return false if (self.s !~ /[\-0-9A-Z]/ || (0 != self.s.gsub(/<20>/, "").gsub(/\s/, "").gsub(/[\-0-9A-Z]/, "").length))
    return true
  end

  def isIpa
    return false if (!self.testFontFamilyAndSize("Ipa"))
    return false if (self.s =~ /[A-Z]{2,}[0-9]/) # in some long phrase, pinyin + ipa is concatenated
    return true if (["<2070>",
                     "<B9>", "<B2>", "<B3>",
                     "<2074>", "<2075>", "<2076>", "<2077>", "<2078>", "<2079>"
                    ].any?{|ss|
                     self.s.include?(ss)
                    })
    return false
  end

  def isMeaning
    r = true
    r = false if (!self.testFontFamilyAndSize("Meaning"))
    r = false if (self.s.decodeQuotedHex.split("").none?{|c| c.startsWithCJK})
    return r
  end

  def isOrigin
    return false if (!self.testFontFamilyAndSize("Origin"))
    return true if (self.s =~ /^S[0-9]/)
    return false
  end

end

class Rect
  def isNewNumber
    return self.data.isNewNumber
  end

  def isPinyin
    return self.data.isPinyin
  end

  def isIpa
    return self.data.isIpa
  end

  def isMeaning
    return self.data.isMeaning
  end

  def isOrigin
    return self.data.isOrigin
  end
end


class Page
  attr_accessor(:words, :pageNumber, :wordsNewNumber, :wordsPinyin, :wordsIpa, :wordsMeaning, :wordsOrigin)
  def initialize
    @words = Array.new
  end

  def isEmpty
    return (@words.length == 0)
  end

  def classifyWords(xRangeMostLeftColumn)
    @wordsNewNumber = @words.select{|w| w.isNewNumber}.sort_by{|w| w.averageY}
    if (@wordsNewNumber.length == 0)
      @wordsNewNumber = @words.select{|w|
        xRangeMostLeftColumn.include?(w.averageX) && w.data.s =~ /^[0-9 ]+$/ && w.data.fontSize == Opts.style_for_column["NewNumber"]["fontSize"]
      }
    end

    xRangePinyin  = @words.select{|w| w.isPinyin }.collect{|w| w.getXRange}.collect{|xr| [xr.first, xr.last]}.flatten.sort
    xRangeIpa     = @words.select{|w| w.isIpa    }.collect{|w| w.getXRange}.collect{|xr| [xr.first, xr.last]}.flatten.sort
    xRangeMeaning = @words.select{|w| w.isMeaning}.collect{|w| w.getXRange}.collect{|xr| [xr.first, xr.last]}.flatten.sort
    xRangeOrigin  = @words.select{|w| w.isOrigin }.collect{|w| w.getXRange}.collect{|xr| [xr.first, xr.last]}.flatten.sort

    xRangePinyin  = (xRangePinyin.min )..(xRangePinyin.max)
    xRangeIpa     = (xRangeIpa.min    )..(xRangeIpa.max)
    xRangeMeaning = (xRangeMeaning.min)..(xRangeMeaning.max)
    xRangeOrigin  = (xRangeOrigin.min )..(xRangeOrigin.max)

    @wordsPinyin  = @words.select{|w| w.isPinyin  && (xRangeIpa.min     == nil || w.x2 < xRangeIpa.min    )}
    @wordsIpa     = @words.select{|w| w.isIpa     && (xRangeMeaning.min == nil || w.x2 < xRangeMeaning.min)}
    @wordsMeaning = @words.select{|w| w.isMeaning && (xRangeOrigin.min  == nil || w.x2 < xRangeOrigin.min )}
    @wordsOrigin  = @words.select{|w| w.isOrigin  && (xRangeMeaning.max == nil || w.x1 > xRangeMeaning.max)}

    # p [ @wordsNewNumber, @wordsPinyin, @wordsIpa, @wordsMeaning, @wordsOrigin]
    STDERR.printf("*** page %d has no New Number!\n", @pageNumber) if (@wordsNewNumber.length == 0)
    return self
  end

  def setCellSizeForNewNumber
    @wordsNewNumber.each_cons(3){|w_prev, w_cur, w_next|
      w_cur.data["cell"] = Rect.new
      w_cur.data.cell.y1 = (w_cur.averageY + w_prev.averageY) * 0.5
      w_cur.data.cell.y2 = (w_cur.averageY + w_next.averageY) * 0.5
    }

    @wordsNewNumber.first.data["cell"] = Rect.new
    y2 = @wordsNewNumber[1].data.cell.y1
    y1 = @wordsNewNumber.first.averageY - (y2 - @wordsNewNumber.first.averageY)
    @wordsNewNumber.first.data.cell.y1 = y1
    @wordsNewNumber.first.data.cell.y2 = y2
    
    @wordsNewNumber.last.data["cell"] = Rect.new
    @wordsNewNumber.last.data.cell.y1 = @wordsNewNumber[-2].data.cell.y2
    @wordsNewNumber.last.data.cell.y2 = @wordsNewNumber.last.averageY + (@wordsNewNumber.last.averageY - @wordsNewNumber.last.data.cell.y1)

    x1 = @wordsNewNumber.collect{|w| w.x1}.min
    x2 = @wordsNewNumber.collect{|w| w.x2}.max
    @wordsNewNumber.each{|w|
      w.data.cell.x1 = x1
      w.data.cell.x2 = x2
    }

    return self
  end

  def assignNewNumberToColumns
    @wordsNewNumber.each do |wnn|
      yRange = wnn.data.cell.getYRange
      @wordsPinyin.each{|w|  w.data["newNumber"] = wnn if (w.data.newNumber == nil && yRange.include?(w.averageY))}
      @wordsIpa.each{|w|     w.data["newNumber"] = wnn if (w.data.newNumber == nil && yRange.include?(w.averageY))}
      @wordsMeaning.each{|w| w.data["newNumber"] = wnn if (w.data.newNumber == nil && yRange.include?(w.averageY))}
      @wordsOrigin.each{|w|  w.data["newNumber"] = wnn if (w.data.newNumber == nil && yRange.include?(w.averageY))}

      wnn.data["pinyin"]  = @wordsPinyin.select{|w| w.data.newNumber == wnn}
      wnn.data["ipa"]     = @wordsIpa.select{|w| w.data.newNumber == wnn}
      wnn.data["meaning"] = @wordsMeaning.select{|w| w.data.newNumber == wnn}
      wnn.data["origin"]  = @wordsOrigin.select{|w| w.data.newNumber == wnn}
    end

    return self
  end

  def to_tsv
    rs = []
    @wordsNewNumber.each do |wnn|
      rs << [
        wnn.data.s,
        wnn.data["pinyin" ].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "")}.join("|"),
        wnn.data["ipa"    ].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "")}.join("|"),
        wnn.data["meaning"].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "")}.join("|"),
        wnn.data["origin" ].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "")}.join("|")
      ].join("\t")
    end
    return rs
  end

  def to_tsv_utf8
    rs = []
    @wordsNewNumber.each do |wnn|
      rs << [
        wnn.data.s,
        wnn.data["pinyin" ].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "").decodeQuotedHex}.join("|"),
        wnn.data["ipa"    ].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "").decodeQuotedHex}.join("|"),
        wnn.data["meaning"].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "").decodeQuotedHex}.join("|"),
        wnn.data["origin" ].collect{|w| w.data.s.gsub(/^\s*/, "").gsub(/\s*$/, "").decodeQuotedHex}.join("|")
      ].join("\t")
    end
    return rs
  end

  def getContentAsArrayOfHash
    rs = Array.new
    @wordsNewNumber.each do |wnn|
      row = Rect.new.from_s(wnn.to_s)
      ["pinyin", "ipa", "meaning", "origin"].each do |clmn|
        if (wnn.data.include?(clmn) && wnn.data[clmn] != nil)
          wnn.data[clmn].each do |wfrag|
            row.extendToCover(wfrag)
          end
        end
      end
      rs << {
          "seq" => wnn.data.s,
          "pinyin" => wnn.data["pinyin"].collect{|w| w.data.s.decodeQuotedHex}.join("\n"),
          "ipa" => wnn.data["ipa"].collect{|w| w.data.s.decodeQuotedHex}.join("\n"),
          "meaning" => wnn.data["meaning"].collect{|w| w.data.s.decodeQuotedHex}.join("\n"),
          "origin" => wnn.data["origin"].collect{|w| w.data.s.decodeQuotedHex}.join("\n"),
          "page" => @pageNumber,
          "geometry" => row.to_s
      }
    end
    return rs
  end

end

pages = Array.new
pageNumber = nil
js = Array.new
while (STDIN.gets)
  # once line fragments are found, skip to next page
  if ($_.include?("*** line fragments ***"))
    while (STDIN.gets)
      break if ($_[0,3] == "***")
    end
    break if ($_ == nil) # maybe EOF
  end

  # once page beginning is found, skip to flows
  if ($_.include?("*** TextOutputDev::startPage "))
    pageNumber = $_.split(/\s+/)[2].to_i
    if (pages.last && !pages.last.isEmpty)
      pastXRanges = pages.select{|pg| !pg.isEmpty && pg.wordsNewNumber}.collect{|pg| pg.wordsNewNumber.collect{|w| w.data.cell.getXRange}}.flatten
      pastXRangeXMin = pastXRanges.collect{|xrng| xrng.first}.min
      pastXRangeXMax = pastXRanges.collect{|xrng| xrng.last}.max
      xRangeMostLeftColumn = pastXRangeXMin..pastXRangeXMax
      # pages.last.classifyWords(xRangeMostLeftColumn).setCellSizeForNewNumber.assignNewNumberToColumns.to_tsv
      if (Opts.gen_json)
        rs = pages.last.classifyWords(xRangeMostLeftColumn).setCellSizeForNewNumber.assignNewNumberToColumns.getContentAsArrayOfHash
        js << rs
      else
        rs = pages.last.classifyWords(xRangeMostLeftColumn).setCellSizeForNewNumber.assignNewNumberToColumns.to_tsv_utf8
        js += rs
      end
   
      # puts JSON.pretty_generate( rs )
    end
    pages << Page.new
    pages.last.pageNumber = pageNumber

    while (STDIN.gets)
      break if ($_.include?("*** flows ***"))
    end
  end

  if ($_ =~ /^\s+word: x=.* \'.*\'$/)
    if (!Opts.check_pages || Opts.check_pages.include?(pageNumber))
      word = Rect.new
      pages.last.words << word
      toks = $_.chomp.gsub(/^\s*/, "").gsub(/\s*$/, "").split(/\s+/, 8)
      toks.shift # discard "word:"
      x1, x2, = toks.shift.split("=").last.split("..").collect{|v| v.to_f}
      y1, y2, = toks.shift.split("=").last.split("..").collect{|v| v.to_f}
      word.setByX1Y1X2Y2(x1, y1, x2, y2)
      word.data = {
        "page"     => pageNumber,
        "base"     => toks[0].split("=").last.to_f,
        "font"     => toks[1].split("=").last,
        "fontSize" => toks[2].split("=").last.to_f,
        # "space"      => toks[3].split("=").last.to_f,
        "s"        => toks[4][1..-2]
      }
      wordClasses = []
      wordClasses << "number" if (word.isNewNumber)
      wordClasses << "pinyin" if (word.isPinyin)
      wordClasses << "ipa" if (word.isIpa)
      wordClasses << "meaning" if (word.isMeaning)
      wordClasses << "origin" if (word.isOrigin)
      # p [pageNumber, $_, wordClasses.join("+")]
    end
  end
end

if (Opts.gen_json)
  puts JSON.pretty_generate(js)
else
  js.each do |aTsvLine|
    puts aTsvLine
  end
end
