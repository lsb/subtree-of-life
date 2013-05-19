require 'oj'
require 'digest/md5'
require 'open-uri'

def greedy_prefixes(original_strings, iterations = 2, min_length = 5, pointer_size = 2)
  prefixes_shortened_strings = original_strings.map {|s| [[],s[0..-1]] }
  prefixes = []
  STDERR.puts [prefixes_shortened_strings.join(' ').length, Time.now, prefixes.length].join(' ~ ')
  iterations.times {
    string_savings = Hash.new(-1)
    prefixes_shortened_strings.each {|_, shortened_string|
      (min_length..shortened_string.length).each {|string_idx|
        string_savings[shortened_string[0,string_idx]] += 1
      }
    }
    best_prefix, best_count = string_savings.max_by {|prefix, count| (prefix.length - pointer_size) * count }
    prefixes_shortened_strings.each {|pfxs, shortened_string|
      if shortened_string.start_with?(best_prefix)
        pfxs << prefixes.length
        shortened_string.slice!(0, best_prefix.length)
      end
    }
    prefixes << best_prefix
    STDERR.puts [prefixes_shortened_strings.join(' ').length, Time.now, prefixes.length, best_prefix.length, best_count].join(' ~ ')
  }
  [prefixes, prefixes_shortened_strings]
end

def e(s) URI.encode_www_form_component(s) end

names_images_taxonomies = STDIN.readlines.map {|line|
  organism = Oj.load(line)
  names = [organism['title'], organism['name']].compact.uniq
  names = [names[0]] if names.length == 2 && names.map(&:downcase).map {|name| name.sub(/e?s$/,'')}.uniq.length == 1
  images = [organism['image']].compact
  full_image_links = images.map {|image_name|
    underscored_name = image_name.tr(' ', '_')
    md5 = Digest::MD5.hexdigest(underscored_name)
    "#{md5[0,1]}/#{md5[0,2]}/#{underscored_name}"
  }
  clean_up_taxon_values = Hash.new {|h, tv| tv }
  clean_up_taxon_values.merge!({"Eukarya" => "Eukarya / Eukaryota", "Eukaryota" => "Eukarya / Eukaryota"})
  taxonomy = organism['taxonomy'].map {|k,v| [e(k),clean_up_taxon_values[e(v)]] }
  names.map {|name| [e(name), e(full_image_links.first), taxonomy.join(" ")] }
}.inject(:concat)

names, images, taxonomies = *names_images_taxonomies.transpose

prefixes, prefixarrays_shorttaxes = *greedy_prefixes(taxonomies, 64, 8, 1)

prefixarrays, shorttaxes = *prefixarrays_shorttaxes.transpose

b36prefixarrays = prefixarrays.map {|a| a.map {|i| sprintf("% 2s", i.to_s(36)) }.join }

output = {'prefixes' => prefixes, 'taxonomies' => [names, images, b36prefixarrays, shorttaxes].transpose.map {|a| a.join("\t") } }

STDOUT.puts(Oj.dump(output))
