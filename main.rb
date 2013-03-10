# Script to read data tables and analyze based on trivial value comparisons
# can be used eg for Gene expression or ChIP-seq analysis

# written by Jonas Marcello (rujmarcello@gmail.com)
# can be used/modified freely for any peaceful purpose
# Aknowledgment would be nice, though





DataPoint = Struct.new(:symbol, :condition, :value, :rank, :percentile)
path = File.dirname(__FILE__)
require path + '/build_table.rb'
require path + '/analyze.rb'
require path + '/output.rb'
