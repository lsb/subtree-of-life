require 'oj'
require 'nokogiri'
require 'open-uri'

$\ = "\n"

STDIN.each {|line|
  organism = Oj.load(line)
  image = organism['image']
  (STDOUT.print(line) ; next ) unless image
  image_page_url = "http://en.wikipedia.org/wiki/File:#{URI::encode(image)}"
  download_and_get_full_image_link = lambda { "http:" + Nokogiri::HTML(`wget -nv --output-document=- "#{image_page_url}"`).css(".fullImageLink a").first["href"] }
  organism_with_maybe_full_image_link = lambda { organism.merge({"image_url" => download_and_get_full_image_link[] }) }
  new_organism = organism_with_maybe_full_image_link[] rescue ((sleep 1) && organism_with_maybe_full_image_link[]) rescue organism
  STDOUT.print(Oj.dump(new_organism))
  sleep 0.5
}

  
