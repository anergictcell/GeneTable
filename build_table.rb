# structure of DataPoint
# DataPoint = Struct.new(:symbol, :condition, :value, :rank, :percentile)

class GeneTable
  attr_reader :symbols, :ranks, :percentiles, :values, :conditions 

  def initialize()

    @idcounter = 0  # will be used for indexing DataPoint in @data 
    @data = Hash.new()  # {id => DataPoint}

    # All following Hashes will be used as indicies
    # They are written in the format:
    # { 
    #  :key1 => [ id1, id2, ..., id(n) ], 
    #  :key2 => ....
    # }
    @conditions = Hash.new()
    @symbols = Hash.new()
    @ranks = Hash.new()
    @percentiles = Hash.new()
    @values = Hash.new() # indexed by (value * 100).round(0).to_i 
      # conversion of values will be done within the class functions
  end


  #
  # add one column of values into data Hash
  # the passed hash has to have the following structure: 
  # {
  #   :symbol1 => value1 (int), 
  #   :symbol2 => ...
  # }
  # 
  # IMPORTANT: ==> This function must never run in parallel! 
  # The ID assignment has to be ordered
  # 
  def add_condition(hash, condition_name)
    raise ArgumentError, "You have to provide a Hash {symbol=>value}" unless (hash.is_a? Hash)
    raise ArgumentError, "conditon_name has to be a Symbol" unless (condition_name.is_a? Symbol)
    raise RuntimeError, "Condition #{condition_name} already exists" if @conditions.has_key? condition_name

    # sort each dataset based on the values
    # That way we immediately can calculate the rank and percentile
    array = hash.to_a.sort_by{|ary| ary[1].to_f}
    
    n = array.length

    # add values for each gene to @data Hash and the indicies
    array.each_with_index do |content, i|
      add_datapoint( content, i, condition_name , n )
    end

  end


private
  def add_datapoint( content, i, condition_name, n )
    rank = n-i     # 1-based, high to low
    
    # calculate percentile: 100(k−1)/(N−1)  
    # // k = rank (1-based, inverted (small to large)
    # // N = number of elements
    percentile = ((100.to_f*(i))/(n-1)).round(0).to_i

    @data[@idcounter] = DataPoint.new( 
      content[0].to_sym, # symbol
      condition_name, 
      content[1].to_f, # raw value
      rank,
      percentile
    )

    append_to_hash_array(@symbols, content[0].to_sym, @idcounter)
    append_to_hash_array(@ranks, rank, @idcounter)
    append_to_hash_array(@percentiles, percentile, @idcounter)
    append_to_hash_array(@values, ((content[1].to_f) * 100 ).round(0).to_i, @idcounter)
    append_to_hash_array(@conditions, condition_name, @idcounter)

    @idcounter += 1
  end

  def append_to_hash_array(hash,key,value)
    if hash.has_key? key then
      hash[key] << value
    else
      hash[key] = [value]
    end
    return true
  end

end