#!/usr/bin/env ruby

class Rect
  attr_accessor(:offsetX, :offsetY, :width, :height)
  attr_accessor(:data)

  def x1
    return @offsetX
  end

  def y1
    return @offsetY
  end

  def x1=(v)
    @offsetX = v
    return self
  end

  def y1=(v)
    @offsetY = v
    return self
  end

  def w
    return @width
  end

  def h
    return @height
  end

  def w=(v)
    @width = v
    return self
  end

  def h=(v)
    @height = v
    return self
  end

  def x2
    return @offsetX + @width
  end

  def y2
    return @offsetY + @height
  end

  def x2=(v)
    @width = v - @offsetX
    return self
  end

  def y2=(v)
    @height = v - @offsetY
    return self
  end

  def averageX
    return @offsetX + (0.5 * @width)
  end

  def averageY
    return @offsetY + (0.5 * @height)
  end

  def sizeOfArea
    return @width * @height
  end

  def setByX1Y1X2Y2(v1, v2, v3, v4)
    # return self.x1=(v1).y1=(v2).x2=(v3).y2=(v4)
    @offsetX = v1
    @offsetY = v2
    @width   = v3 - v1
    @height  = v4 - v2
    return self
  end

  def setByX1Y1X2Y2Arr(arr)
    return self.setByX1Y1X2Y2(arr[0], arr[1], arr[2], arr[3])
  end

  def setByXYWH(v1, v2, v3, v4)
    @offsetX = v1
    @offsetY = v2
    @width   = v3
    @height  = v4
    return self
  end

  def setByXYWHArr(arr)
    return self.setByXYWH(arr[0], arr[1], arr[2], arr[3])
  end

  def setByCenterXYAndWH(x, y, w, h)
    @offsetX = x - (0.5) * w
    @offsetY = y - (0.5) * h
    @width = w
    @height = h
    return self
  end

  def from_s(s)
    toks = s.split("_")
    @width, @height, @offsetX, @offsetY = toks.pop.split(/[x\+]/).collect{|t| t.to_f}
    if (toks.last =~ /^rot/)
      @data["rot"] = toks.pop.gsub(/^rot/, "").to_f
    end
    return self
  end

  def to_s
    s = sprintf("%04dx%04d+%04d+%04d", @width, @height, @offsetX, @offsetY)
    if (@data != nil && @data["rot"] != nil)
      s = sprintf("rot%s%4.2f_", (@data["rot"] < 0 ? "-" : "+"), @data["rot"].abs) + s
    end
    return s
  end

  def to_json_hash
    hs = @data.clone
    hs["offsetX"] = @offsetX
    hs["offsetY"] = @offsetY
    hs["width"]   = @width
    hs["height"]  = @height
    return hs
  end

  def setByLibXmlElment(e)
    @offsetX = e.attributes["x"]
    @offsetY = e.attributes["y"]
    @width   = e.attributes["width"]
    @height  = e.attributes["height"]
    return self
  end

  def copyToXmlAttrHash(e)
    e.attributes["x"] = @offsetX.to_s
    e.attributes["y"] = @offsetY.to_s
    e.attributes["width"] = @width.to_s
    e.attributes["height"] = @height.to_s
    (@data.keys - ["x", "y", "width", "height"]).each do |k|
      e.attributes[k] = @data[k].to_s
    end
    return e
  end

  def to_libxml_node
    return self.copyToXmlAttrHash(LibXML::XML::Node.new("rect"))
  end

  def getQuantized
    qcr = Rect.new.setByXYWH(@offsetX.to_i, @offsetY.to_i, @width.to_i, @height.to_i)
    qcr.data = @data.clone
    return qcr
  end

  def hasOverlapWith(another)
    if ((self.w + another.w) < [self.x2, another.x2].max - [self.x1, another.x1].min)
      return false
    elsif ((self.h + another.h) < [self.y2, another.y2].max - [self.y1, another.y1].min)
      return false
    else
      return true
    end
  end

  def getOverlapWith(another)
    if (self.hasOverlapWith(another))
      xs = [self.x1, self.x2, another.x1, another.x2].sort
      ys = [self.y1, self.y2, another.y1, another.y2].sort
      return Rect.new.setByX1Y1X2Y2(xs[1], ys[1], xs[2], ys[2])
    end
    return nil
  end

  def includesCenterOf(another)
    if (((self.x1)..(self.x2)).include?(another.averageX) && ((self.y1)..(self.y2)).include?(another.averageY))
      return true
    end
    return false
  end

  def covers(another)
    if (((self.x1)..(self.x2)).include?(another.x1) && ((self.y1)..(self.y2)).include?(another.y1) &&
        ((self.x1)..(self.x2)).include?(another.x2) && ((self.y1)..(self.y2)).include?(another.y2))
      return true
    end
    return false
  end

  def getSupersetWith(another)
    return Rect.new.setByX1Y1X2Y2( [self.x1, another.x1].min,
                                   [self.y1, another.y1].min,
                                   [self.x2, another.x2].max,
                                   [self.y2, another.y2].max )
  end

  def extendToCover(another)
    return self.setByX1Y1X2Y2( [self.x1, another.x1].min,
                               [self.y1, another.y1].min,
                               [self.x2, another.x2].max,
                               [self.y2, another.y2].max )
  end

  def makeRectForRot(rN)
    rOld = self.data["rot"] * Math::PI / 180.0
    rNew = rN * Math::PI / 180.0

    l0 = Math::sqrt(self.x1**2 + self.y1**2)
    r0 = Math::atan2(y1, x1) + rOld
    x0 = l0 * Math::cos(r0 - rNew)
    y0 = l0 * Math::sin(r0 - rNew)

    l1 = Math::sqrt(self.x2**2 + self.y1**2)
    r1 = Math::atan2(y1, x2) + rOld
    x1 = l0 * Math::cos(r1 - rNew)
    y1 = l0 * Math::sin(r1 - rNew)

    l2 = Math::sqrt(self.x1**2 + self.y2**2)
    r2 = Math::atan2(y2, x1) + rOld
    x2 = l2 * Math::cos(r2 - rNew)
    y2 = l2 * Math::sin(r2 - rNew)

    l3 = Math::sqrt(self.x2**2 + self.y2**2)
    r3 = Math::atan2(y2, x2) + rOld
    x3 = l3 * Math::cos(r3 - rNew)
    y3 = l3 * Math::sin(r3 - rNew)

    xs = [x0, x1, x2, x3].sort
    ys = [y0, y1, y2, y3].sort

    r = Rect.new.setByX1Y1X2Y2(xs.first.ceil, ys.first.ceil, xs.last.floor, ys.last.floor)
    r.data = self.data.clone
    r.data["rot"] = rN
    return r
  end

  def resize(f)
    r = Rect.new.setByXYWH(@offsetX * f, @offsetY * f, @width * f, @height * f)
    r.data = self.data.clone
    return r
  end

  def resize!(f)
    @offsetX = @offsetX * f
    @offsetY = @offsetY * f
    @width   = @width * f
    @height  = @height * f
    return self
  end

end
