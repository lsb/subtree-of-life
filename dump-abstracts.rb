require '~/sax-machine/lib/sax-machine' # greg weber's fork of saxmachine with lazy parsing

$, = "\t"  # output field separator
$\ = "\n"  # output record separator

class Doc
  include SAXMachine
  element :title
  element :abstract
end

class Feed
  include SAXMachine
  elements :doc, :lazy => true, :as => :docs, :class => Doc # the feed has too many docs to not parse :lazy
end


Feed.parse(STDIN, :lazy => true).docs.each {|doc|
  title = doc.title
  abstract = doc.abstract
  next if title.nil? || abstract.nil?
  stripped_title = title.sub(/^Wikipedia: /,'')
  respaced_abstract = abstract.gsub(/\s+/, ' ')
  STDOUT.print(stripped_title, respaced_abstract)
}
