#!/usr/bin/env ruby1.9
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

lines = Array.new
while (STDIN.gets)
  next if ($_.chomp !~ /1B[3-5][0-9A-F]{2}.*SHUISHU/)

  toks = $_.chomp.gsub(/^\s*/, "").gsub(/\s*$/, "").split(/\s+/)

  ucsHex = toks[0]
  ucsInt = toks[1].encode("UCS-4BE").unpack("N").first
  next if (ucsHex.hex != ucsInt)

  next if (toks[2] != "SHUISHU")

  next if (toks[3] !~ /^RADICAL-[0-9]+(-[A-Z])?$/ &&
           toks[3] != "LOGOGRAM")

  charName = toks[2..-1].join(" ")

  lines << sprintf("U+%04X\t%s", ucsInt, charName)
end

lines.sort.each do |l|
  puts l
end
