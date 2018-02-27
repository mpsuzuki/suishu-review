class String
  def startsWithCJK
    ucsInt = self.encode("UCS-4BE").unpack("N").first
    return true if ((0x3400..0x4DBF).include?(ucsInt)) # ExtA
    return true if ((0x4E00..0x9FFF).include?(ucsInt)) # URO
    return true if ((0xF800..0xFAFF).include?(ucsInt)) # CmptBMP
    return true if ((0x20000..0x2FFFF).include?(ucsInt)) # SIP
    return false
  end

  def isSingleCJK
    return false if (self.length != 1)
    return self.startsWithCJK
  end

  def isEntityRef
    return false if (self[0..0] != "&")
    return false if (self[-1..-1] != ";")
    return false if (self[1..-2].include?("&"))
    return false if (self[1..-2].include?(";"))
    return true
  end

  def getEntityRef
    return nil if (self[0..0] != "&") 
    return nil if (!self.include?(";")) 
    er = (self.split(";", 2).first) + ";"
    return nil if (!er.isEntityRef)
    return er
  end

  def getBodyFromEntityRef
    return nil if (!self.isEntityRef)
    return self[1..-2]
  end

  def getBasenameAsStrFromEntityRef
    b = self.getBodyFromEntityRef
    return nil if (!b)
    return b.split("_", 2).first
  end

  def getBasenameFromEntityRef
    b = getBasenameAsStrFromEntityRef
    return nil if (!b)
    return b if (b.isSingleCJK)
    return ("&" + b + ";")
  end

  def getNumDeltaFromEntityRef
    b = self.getBodyFromEntityRef
    return nil if (!b)
    return b.split("_").last.to_i
  end

  def getAsciiDeltaFromEntityRef
    b = self.getBodyFromEntityRef
    return nil if (!b)
    toks = b.split("_")
    return nil if (toks.last.length > 1)
    return toks.last.downcase.encode("ascii").unpack("C").first - "a".encode("ascii").unpack("C").first
  end

  def getBookIdFromEntityRef
    b = self.getBodyFromEntityRef
    return nil if (!b)
    toks = b.split("_")[1..-1]
    toks = toks.select{|t| t.length > 1}
    return nil if (toks.length == 0) 
    return toks.last.upcase
  end

  def decodeQuotedHex
    toks = self.split("<") 
    prefix = toks.shift
    toks = toks.collect{|t|
      ucsHex, postfix = t.split(">", 2)
      ucsRaw = [ucsHex.hex].pack("N").encode("utf-8", "ucs-4be")
      (ucsRaw + postfix)
    }
    toks.unshift(prefix)
    return toks.join("")
  end
end
