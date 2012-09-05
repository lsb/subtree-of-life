require '~/sax-machine/lib/sax-machine' # greg weber's fork of saxmachine with lazy parsing
require 'oj'
require 'andand'

$\ = "\n"  # output record separator

class Revision
  include SAXMachine
  element :text
end

class Page
  include SAXMachine
  element :title
  element :revision, :class => Revision
end

class MediaWiki
  include SAXMachine
  elements :page, :lazy => true, :as => :pages, :class => Page #too many pages to load into memory at once, so do a :lazy parse
end

# It's vastly simpler if we don't run MediaWiki itself, and just tear out the taxonomy infobox with a regular expression.
# Wikimarkup can nest arbitrarily deeply, though; the pumping lemma implies that a regular expression won't work in the general case.
# Practically, for a taxobox there's under 2 levels of nesting, so pump 4 times.

def pump(base, i, &oneup)
  i.zero? ? base : pump(oneup.call(base), i-1, &oneup)
end

QuadrupleNestedBraces = pump('[^{]+', 4) {|base| '(?>[^{}]|\{\{' + base + '\}\})+' }
TaxoboxRegexp = /\{\{taxobox#{QuadrupleNestedBraces}\}\}/mi

MediaWiki.parse(STDIN, :lazy => true).pages.each {|page|
  title = page.title
  taxobox = page.revision.text.andand[TaxoboxRegexp]
  next unless taxobox
  STDOUT.print(Oj.dump([title, taxobox]))
}
