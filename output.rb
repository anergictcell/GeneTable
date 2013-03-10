class GeneTable

  # returns a tab separated table
  # each row represents one gene
  # each columns represents values of one dataset
  # the first column lists the gene symbol
  # params: {
  #  :condition1 => :kind_of_value,
  #  :condition2, ....
  # }

  def make_table(symbols, params)
    sep = "\t"  # separating the columns
    # printing header
    header = ["symbol"]
    params.each do |cond, kind|
      header << "#{cond}.#{kind}"
    end
    string = [header.join(sep)]
    # end of header

    # printint data
    symbols.each do |symbol|
      line = ["#{symbol}"]
      params.each do |condition, kind|
        # Searching for the gene symbol in one condition returns
        # Array with size 1
        dp = ids_to_dp(get_subset_ids(condition, :symbol, [symbol]))[0]
        line << "#{dp[kind]}"
      end
      string << line.join(sep)
    end
    return string.join("\n")+"\n" # Adding extra \n to have complete data rows
  end

  ###################### PRINTING TABLES WITH ALL DATA ####################
  def print(ids = nil)
    string = "[ID]\t"
    string << "[MGI SYMBOL]\t"
    string << "[CONDITION]\t"
    string << "[VALUE]\t"
    string << "[RANK]\t"
    string << "[PERCENTILE]\n"

    if ids.nil?
      @data.each do |key, value|
        string << add_string(key, value)
      end
    else
      ids.each do |id|
        string << add_string(id, @data[id])
      end
    end
    return string
  end

  def print_cropped(params = {})
    # params = {
    #  :width => {
    #    :id => int, :symbol => int, ...
    #  },
    #  :ids => [1,2,...n]
    # }

    width = params[:width] || {}
      width[:id] ||= 6
      width[:symbol] ||= 12
      width[:condition] ||= 11
      width[:value] ||= 7
      width[:rank] ||= 6
      width[:percentile] ||= 12
 
    string = csw("[ID]",width[:id]) + "\t"
    string << csw("[MGI SYMBOL]",width[:symbol]) + "\t"
    string << csw("[CONDITION]",width[:condition]) + "\t"
    string << csw("[VALUE]",width[:value]) + "\t"
    string << csw("[RANK]",width[:rank]) + "\t"
    string << csw("[PERCENTILE]",width[:percentile]) + "\n"

    if params[:ids].nil?
      @data.each do |key, value|
        string << add_cropped_string(key, value, width)
      end
    else
      params[:ids].each do |id|
        string << add_cropped_string(id, @data[id], width)
      end
    end
    return string
  end


private
  def add_string(key,value)
    string = ""
    string << key.to_s + "\t"
    string << value[0].to_s + "\t"
    string << value[1].to_s + "\t"
    string << value[2].to_s + "\t"
    string << value[3].to_s + "\t"
    string << value[4].to_s + "\n"
  end

  def add_cropped_string(key, value, width)
    string = ""
    string << csw(key.to_s, width[:id]) + "\t"
    string << csw(value[0].to_s, width[:symbol]) + "\t"
    string << csw(value[1].to_s, width[:condition]) + "\t"
    string << csw(value[2].to_s, width[:value]) + "\t"
    string << csw(value[3].to_s, width[:rank]) + "\t"
    string << csw(value[4].to_s, width[:percentile]) + "\n"
  end

  def csw(s,w)  # change_string_width
    s << " " * w
    return s[0..w]
  end

end