require 'uri'
require 'json'

e = URI.method(:encode_www_form_component)

STDIN.readlines.each{|line|
  j=JSON.parse(line)
  new_name = [j["title"], j["name"]].compact.uniq.join(" / ")
  new_taxonomy = j["taxonomy"].map {|k,v| e[k]+":"+e[v] }.join(",")
  puts [e[new_name], e[JSON.dump([j['image'], j['image2']].compact)], new_taxonomy].join(' ')
}
