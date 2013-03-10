#
# LARGE TEST DATASET 
# Since this dataset is based on randomized values, it can not be used for
# testing the analysis functions. 
#

# But it can be used for benchmarking, 
# as the size is similar to real life applications for the script

require './main.rb'


# Creating data to insert into GeneTable
num_datasets = 100
conditions = num_datasets.times.map{|x| "cond#{x}"}
genes = Hash.new
20000.times { |x| genes["gene#{x}".to_sym] = rand()*50 }

puts
puts "-------------------"
puts
puts "Reading in datasets"
x = GeneTable.new
conditions.each_with_index do |con, i|
  x.add_condition(genes, con.to_sym)
  print "\r#{i+1} / #{num_datasets}"
end
puts "                                             "
puts "Done"
puts
puts "-------------------"
puts
t = Time.now
needles = (90..100).map {|x| x}
ids = x.get_subset_ids(:cond3, :percentile, needles)
t2 = Time.now
print "Size of ids array:  "
puts ids.size

t3 = Time.now
dps = x.get_subset_dps(:cond3, :percentile, needles)
t4 = Time.now
print "Size of dps array:  "
puts dps.size

puts
puts "-------------------"
puts

puts "Time for generating IDs:  #{t2-t}" 
puts "Time for generating DPs:  #{t4-t3}"
