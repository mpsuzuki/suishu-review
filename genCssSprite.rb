#!/usr/bin/env ruby1.9

stylePerPage = Hash.new
stylePerUcs = Array.new

while (STDIN.gets)
  toks = $_.chomp.split(/\s+/)
  ucs = toks.shift
  w = (toks.shift.to_f / 8.0).ceil
  h = (toks.shift.to_f / 8.0).ceil
  x = (toks.shift.to_f / 8.0).floor
  y = (toks.shift.to_f / 8.0).floor
  page = toks.shift.to_i

  if (stylePerPage[page.to_s] == nil)
    stylePerPage[page.to_s]  = sprintf("img.n4922-%2d {\n", page)
    stylePerPage[page.to_s] += sprintf("\tbackground: url(\"n4922-r075-%03d.gif\") no-repeat;\n", page)
    stylePerPage[page.to_s] += sprintf("\twidth: %dpx;\n", w)
    stylePerPage[page.to_s] += sprintf("\theight: %dpx;\n", h)
    stylePerPage[page.to_s] += sprintf("}\n")
  end

  cssKVs = Array.new
  # cssKVs << [ "background", ("url(\"gif-oe-n4922/n4922-r600-%03d.gif\") no-repeat" % page) ].join(": ")
  # cssKVs << [ "width",  w.to_s + "px" ].join(": ")
  # cssKVs << [ "height", h.to_s + "px" ].join(": ")
  cssKVs << [ "background-position", [(-x).to_s, (-y).to_s].collect{|s| s + "px"}.join(" ") ].join(": ")

  # stylePerUcs << ("img." + ucs.gsub("+", "-") + " {\n\t" + cssKVs.join(";\n\t") + ";\n}")
  stylePerUcs << ("img." + ucs.gsub("+", "-") + " { " + cssKVs.join("; ") + "; }")
end

stylePerPage.each do |page, s|
  if (s != nil && s.length > 0)
    puts s
  end
end

stylePerUcs.each do |s|
  if (s != nil && s.length > 0)
    puts s
  end
end
