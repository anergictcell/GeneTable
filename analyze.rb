class GeneTable

################# GETTING SUBSETS OUT OF THE DATA TABLE #######################
  
  #
  # returns an Array of DataPoint IDs
  # receives a key of the @datasets Hash to be used as datasource
  # receives the column that should be searched (haystack) eg :value, :rank etc
  # reveives an array of needles that are used as query
  #
  def get_subset_ids(dataset, haystack, needles)
    raise RuntimeError, "haystack has to be Symbol" unless haystack.is_a? Symbol
    raise RuntimeError, "needles has the be Array" unless needles.is_a? Array

    # ALL IDs in the given dataset have to be within this range of IDs
    idrange = [@datasets[dataset.to_sym].first , @datasets[dataset.to_sym].last]
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
  # receives a key of the @datasets Hash to be used as datasource
  # receives the column that should be searched (haystack) eg :value, :rank etc
  # reveives an array of needles that are used as query
  #
  def get_subset_dps(dataset, haystack, needles)
    return ids_to_dp( get_subset_ids(dataset, haystack, needles) )
  end
  
  #
  # converts a subset of genes to DP IDs from another dataset
  # see get_subset_dps for specifics
  # 
  def subset_to_another(dataset, haystack, needles, dataset2)
    symbols = dps_to_symbols( get_subset_dps(dataset, haystack, needles) )
    return get_subset_ids( dataset2, :symbol, symbols )
  end


  #
  # Chain together selections of subsets
  # Define one subset as data source
  # Specify tests for the resulting dataset and narrow it down further
  # Each test has to be passed as Proc together with a dataset on which to test
  # 
  def pipeline(starting_set, selections)
    # format of starting_set:
    #  [ :dataset, :haystack, [needles] ]
    # format of selections:
    # [ [:dataset, Proc], [:dataset, Proc] ]
    # Proc has to return boolean

    raise ArgumentError, "starting_set has to be Array" unless starting_set.is_a? Array
    raise ArgumentError, "selections has to be Array" unless selections.is_a? Array

    # Get startinng dataset and convert to gene symbols
    dps = get_subset_dps( starting_set[0].to_sym, starting_set[1].to_sym, starting_set[2] )
    symbols = dps_to_symbols( dps )

    # Narrow done dataset based on each given dataset
    selections.each do |selection|
      raise ArgumentError, "each selection has to be Array" unless selection.is_a? Array
      raise ArgumentError, "You have to provide a Proc" unless selection[1].is_a? Proc
      
      # get DPs from other dataset
      new_dps = get_subset_dps( selection[0].to_sym, :symbols, symbols )
      
      # select subset based on Proc passed
      new_dps.select! {|set| selection[1].call(set) }
      # and overwrite symbols with the narrowed down dataset for next iteration
      symbols = dps_to_symbols( new_dps )
    end

    return symbols
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
    when "datasets" , "dataset"
      @datasets[identifier.to_sym]
    else
      raise ArgumentError, "kind is not known."
    end

    return list
  end


end