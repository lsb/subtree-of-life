greedy_iterations = 100

original_strings = STDIN.read.split("\n")

shortened_strings = original_strings.map {|s| [[],s[0..-1]] }

prefixes = []

greedy_iterations.times {
  h = Hash.new(-1) # a string seen once has zero savings
  shortened_strings.each {|_,s| s.length.times {|i| h[s[0..i]] += 1 } }
  best_prefix, _ = h.max_by {|prefix, count| prefix.length * count }
  bpl = best_prefix.length
  shortened_strings.each {|a,s|
    if s.start_with?(best_prefix)
      a << prefixes.length
      s.slice!(best_prefix)
    end
  }
  prefixes << best_prefix
  STDERR.puts shortened_strings.join(' ').length
  STDERR.puts Time.now
}

STDOUT.puts prefixes
