#!/usr/bin/env ruby1.9

while (STDIN.gets)
  toks = $_.chomp.split(/\s+/)
  ucs = toks.shift
  w = (toks.shift.to_f / 8.0).ceil
  h = (toks.shift.to_f / 8.0).ceil
  x = (toks.shift.to_f / 8.0).floor
  y = (toks.shift.to_f / 8.0).floor
  page = toks.shift.to_i
  cssKVs = Array.new
  cssKVs << [ "background", ("url(\"gif-oe-n4922/n4922-r600-%03d.gif\") no-repeat" % page) ].join(": ")
  cssKVs << [ "width",  w.to_s + "px" ].join(": ")
  cssKVs << [ "height", h.to_s + "px" ].join(": ")
  cssKVs << [ "background-position", [(-x).to_s, (-y).to_s].collect{|s| s + "px"}.join(" ") ].join(": ")


  puts ("img." + ucs.gsub("+", "-") + " {\n\t" + cssKVs.join(";\n\t") + ";\n}")
end
