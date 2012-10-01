require 'oj'

$\ = "\n" # output record separator

InterestingTaxoboxEntries = %w[name image image2]
Taxonomy = %w[virus_group superdomain domain superregnum unranked_regnum regnum subregnum superdivisio superphylum divisio unranked_divisio unranked_phylum phylum subdivisio subphylum infraphylum microphylum nanophylum superclassis unranked_classis classis unranked_subclassis subclassis unranked_infraclassis infraclassis magnordo superordo unranked_ordo ordo subordo infraordo parvordo zoodivisio zoosectio zoosubsectio unranked_superfamilia superfamilia familia subfamilia supertribus unranked_tribus tribus subtribus alliance unranked_genus genus subgenus sectio subsectio series subseries species_group species_subgroup species_complex species subspecies variety]
TaxoboxKVFormat = / *\| *([a-z0-9_]+) *= *((?:.(?![|]\s))+)/

def remove_wikimarkup(str) str.gsub(/<\/?br ?\/?>/i,"\n").strip end
def remove_markup(str)
  # It's important to note that the data from Wikipedia is noisy. People verify correctness with a visual parse, not a semantic parse.
  str.tr("\t","").
      sub(/<0001:SOAFNA>/,""). # special case.
      gsub(/<small>([^<]+)<\/small>/i,""). # *_authority is rendered smaller, so people just use small; STOL does not use that data
      gsub(/<!--[^>]+->/,""). # comments are invisible
      gsub(/<nowiki>([^<]++)<\/nowiki>/,"\\1"). # we'll pull out most of the wiki markup anyway.
      gsub(/<ref[^<>\/]++\/>/,"").gsub(/<ref[^>]*+>[^<]*+<\/ref>/im,""). # STOL does not have footnotes
      gsub(/''+/,"")  # remove italics/bolding from text
end

STDIN.each {|line|
  title, taxobox = Oj.load(line)
  taxoboxKVs = remove_markup(taxobox).scan(TaxoboxKVFormat)
  name_images = InterestingTaxoboxEntries.map {|k| taxoboxKVs.assoc(k) }.compact.map {|meta, meta_value| [meta, meta_value.strip] }.find_all {|meta, meta_value| meta_value[/[^ ]/] }
  
  available_taxa = Taxonomy.map {|taxon| taxoboxKVs.assoc(taxon) }.compact.map {|taxon, taxon_value| [taxon, remove_wikimarkup(taxon_value)] }
  taxonomy = [["taxonomy", available_taxa]]
  page_title = [["title", title]]
  STDOUT.print(Oj.dump(Hash[page_title + name_images + taxonomy]))
}
