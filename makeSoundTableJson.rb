#!/usr/bin/env ruby1.9
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require "json"
require "./getOpts.rb"
require "./parseSoundTable.rb"

parseSoundTable(STDIN)
js = {"_sound_table" => Opts.sound_table}

puts JSON.pretty_generate(js)
