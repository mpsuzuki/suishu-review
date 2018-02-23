module Hash_UseMissingMethodAsHashKey
  def method_missing(mth, *args)
    if (mth[-1..-1] == "=")
      self[mth[0..-2]] = args[0]
      return self
    end
    if (self.include?(mth))
      return self[mth] 
    end

    hph_key = mth.to_s.gsub("_", "-")
    if (self.include?(hph_key))
      return self[hph_key]
    end

    hph_key = mth.to_s.gsub(/([^A-Z])([A-Z])/, '\1 \2').split(" ").collect{|t| t[0..0].downcase + t[1..-1]}.join("-")
    if (self.include?(hph_key))
      return self[hph_key]
    end

    return nil
  end
end

if (!Object.const_defined?("Opts"))
  Opts = {
    "args" => []
  }
end
Opts.extend(Hash_UseMissingMethodAsHashKey)

while (o = ARGV.shift)
  if (o =~ /^--disable-/ || o =~ /--without-/ || o =~ /--no-/)
    k = o[2..-1].split("-",2).last
    Opts[k] = false
  elsif (o =~ /^--enable-/ || o =~ /--with-/)
    k = o[2..-1].split("-",2).last
    Opts[k] = true
  elsif (o[0..1] == "--" && o[2..-1].include?("="))
    k, v = o[2..-1].split("=", 2)

    if (v =~ /^[0-9]+$/)
      v = v.to_i
    elsif (v =~ /^(\-|\+)[0-9]+$/)
      v = v.to_i
    elsif (v =~ /^(\-|\+|)[0-9]*\.[0-9]+$/)
      v = v.to_f
    end

    if (!Opts.include?(k))
      Opts[k] = v
    elsif (Opts[k].class == Array)
      Opts[k] << v
    else
      Opts[k] = [Opts[k], v]
    end
  elsif (o[0..1] == "--")
    Opts[o[2..-1]] = true
  elsif (o[0..0] == "-")
    if (ARGV.first =~ /^-/)
      Opts[o[1..-1]] = true
    else
      Opts[o[1..-1]] = ARGV.shift
    end
  else
    Opts["args"] << o
  end
end

if (Opts.locale_encoding)
  true
elsif (ENV.include?("LC_CTYPE"))
  Opts.local_encoding = ENV["LC_CTYPE"].split(".").last.split("@").first
elsif (ENV.include?("LANG"))
  Opts.local_encoding = ENV["LANG"].split(".").last.split("@").first
else
  Opts.local_encoding = "utf8"
end
