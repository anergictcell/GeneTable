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


__END__

Usage:

x = GeneTable.new # create an empty new Table
x.prevent(["Cd4","Sfi1"]) # prevent some genes from being incorporated

# add datasets
# add as Array of gene,value pairs
x.add_condition([ ["genename",value], ["gene2",value2] ], :name_of_dataset)
# add as Hash
x.add_condition( {"genename" => value, "gene2" => value2}, :name_of_dataset)
# Gene names can be given as either String or Symbol

# analyze the data

# get all DataPoints for genes with name "Actb" or "Hprt" in dataset "naive"
x.get_subset_dps(:naive, :symbols, ["Actb","Hprt"])

# Chain several tests to each other
# Origin: x[:percentile] > 50
test1 = lambda {|x| x[:value] > 10}
test2 = lambda {|x| x[:percentile] > 80}
x.pipeline( [:naive, :percentile, (50..100).to_a], [[:naive, test1] , [:naive, test2] ] )


