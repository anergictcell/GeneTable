class GeneTable

################# GETTING SUBSETS OUT OF THE DATA TABLE #######################
  
  #
  # returns an Array of DataPoint IDs
  # receives a key of the @conditions Hash to be used as datasource
  # receives the column that should be searched (haystack) eg :value, :rank etc
  # reveives an array of needles that are used as query
  #
  def get_subset_ids(condition, haystack, needles)
    raise RuntimeError, "haystack has to be Symbol" unless haystack.is_a? Symbol
    raise RuntimeError, "needles has the be Array" unless needles.is_a? Array

    # ALL IDs in the given condition have to be within this range of IDs
    idrange = [@conditions[condition].first , @conditions[condition].last]

    ids = []
    needles.each do |needle|
      if ( res = list(haystack, needle) )
        res.each do |id|
          # this assumes the list array is sorted
          next if id < idrange[0]
          break if id > idrange[1]
          ids << id
        end
      end
    end
    return ids
  end

  #
  # returns an Array of DataPoints
  # receives a key of the @conditions Hash to be used as datasource
  # receives the column that should be searched (haystack) eg :value, :rank etc
  # reveives an array of needles that are used as query
  #
  def get_subset_dps(condition, haystack, needles)
    return ids_to_dp( get_subset_ids(condition, haystack, needles) )
  end
  
  #
  # converts a subset of genes to DP IDs from another condition
  # see get_subset_dps for specifics
  # 
  def subset_to_another(condition, haystack, needles, condition2)
    symbols = dps_to_symbols( get_subset_dps(condition, haystack, needles) )
    return get_subset_ids( condition2, :symbol, symbols )
  end


################ CONVERTING BETWEEN ID DPS SYMBOLS ETC ########################

  # converts IDs into DataPoints
  def ids_to_dp(ids)
    raise ArgumentError, "ids has to be Array" unless ids.is_a? Array
    return ids.map { |id| @data[id] }
  end

  # returns the symbol of each Datapoint
  def dps_to_symbols(dps)
    return dps.map {|dp| dp[:symbol] }
  end




private
  #
  # returns an Array of DataPoint object IDs containing all DataPoints with 
  # the given identifier in its Datapoint[kind]
  #
  def list(kind, identifier)
    list = case kind.to_s
    when "symbols" , "symbol"
      @symbols[identifier.to_sym]
    when "ranks" , "rank"
      @ranks[identifier.to_i]
    when "percentiles" , "percentile"
      @percentiles[identifier.to_i]
    when "values" , "value"
      @values[(identifier.to_f * 100).round(0).to_i]
    when "conditions" , "condition"
      @conditions[identifier.to_sym]
    else
      raise ArgumentError, "kind is not known."
    end

    return list
  end


end