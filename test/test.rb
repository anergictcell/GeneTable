require './main.rb'
require 'test/unit'

class TestReading < Test::Unit::TestCase
  def setup
    naive = {:Actb=>47.36290601200503, :Hprt=>44.95969398832746, :Gapdh=>39.18760550082034, :Tbp=>37.71327691492281, :Il1=>13.345922886911621, :Il2=>39.30907959929534, :Il3=>30.47150006261991, :Il4=>32.19696698643171, :Il5=>10.578357959237799, :Il6=>12.747837603316691, :Il7=>11.942686779376272, :Il8=>29.191279656596564, :Il9=>31.808581537244308, :Il10=>15.9130562333352, :Somerandomgenewithaverylongname=>28.38425289498702, :RIKESOMETHING=>32.74482110633792, :ENSMBL2348712341234=>13.768627017941531}
    x2 = {:Actb=>22.40193329385584, :Hprt=>44.88765128737525, :Gapdh=>23.69606208634944, :Tbp=>3.247909254903375, :Il1=>20.124040321783877, :Il2=>9.180291624003623, :Il3=>16.326561485118425, :Il4=>6.210487867212105, :Il5=>35.07068177331485, :Il6=>10.742398821953708, :Il7=>2.4010038572968906, :Il8=>5.462878873256366, :Il9=>32.55935911262216, :Il10=>8.34874812283889, :Somerandomgenewithaverylongname=>23.68181042434452, :RIKESOMETHING=>15.510734676272003, :ENSMBL2348712341234=>18.263724152431877}
    x4 = {:Actb=>29.685697609943272, :Hprt=>42.82201471565351, :Gapdh=>12.70845039948516, :Tbp=>1.691881847425608, :Il1=>16.085108161871826, :Il2=>25.88809906197508, :Il3=>15.47491493643786, :Il4=>12.003668259123634, :Il5=>30.248650116524356, :Il6=>20.985443642860197, :Il7=>34.06889942777184, :Il8=>26.248769147318285, :Il9=>44.0459205532001, :Il10=>16.31733869218594, :Somerandomgenewithaverylongname=>13.455973629242834, :RIKESOMETHING=>43.63878848840646, :ENSMBL2348712341234=>10.574807024044208}
    x6 = [[:Actb,1.6887321837061098], [:Hprt,3.477544244497], [:Gapdh,17.4720603923171], [:Tbp,47.808856483899], [:Il1,3.0299062688469], [:Il2,42.480463937019], [:Il3,6.4387998889555], [:Il4,24.861491913345], [:Il5,31.064100264127], [:Il6,23.2440309737786], [:Il7,40.615678878950], [:Il8,49.465138093409], [:Il9,34.227551669764], [:Il10,39.13345774460], [:Somerandomgenewithaverylongname,8.1168798097951], [:RIKESOMETHING,29.7575862920118], [:ENSMBL2348712341234,5.632376713173709]]
    x12 = {:Actb=>10.374594503886298, :Hprt=>15.749653331422591, :Gapdh=>21.752832206252798, :Tbp=>21.747676832494122, :Il1=>4.005982373326727, :Il2=>43.886055636299204, :Il3=>38.84762213474941, :Il4=>6.397334328662929, :Il5=>0.5705017758357356, :Il6=>45.035482879399765, :Il7=>28.773388461400152, :Il8=>25.32914201003743, :Il9=>14.029794505919746, :Il10=>19.553358186051423, :Somerandomgenewithaverylongname=>5.960983797664587, :RIKESOMETHING=>10.904378569777485, :ENSMBL2348712341234=>17.039558541663286}
    @x = GeneTable.new
    @x.add_condition(naive , :naive)
    @x.add_condition(x2, :hrs2)
    @x.add_condition(x4, :hrs4)
    @x.add_condition(x6, :hrs6)
    @x.add_condition(x12, :hrs12)
  end

  def test_building()
    assert_equal(@x.symbols.keys, [:Il5, :Il7, :Il6, :Il1, :ENSMBL2348712341234, :Il10, :Somerandomgenewithaverylongname, :Il8, :Il3, :Il9, :Il4, :RIKESOMETHING, :Tbp, :Gapdh, :Il2, :Hprt, :Actb])
    assert_equal(@x.ranks.keys, [17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
  end

  def test_analysis()
    needles = (70..95).map {|x| x}
    assert_equal(@x.get_subset_ids(:naive, :percentile, [10,11,12,13,14,15,16,17]), [2] )
    assert_equal(@x.get_subset_dps(:naive, :percentile, [10,11,12,13,14,15,16,17]), @x.ids_to_dp([2]) )
    assert_equal(@x.dps_to_symbols(@x.get_subset_dps(:naive, :percentile, needles) ), [:Tbp, :Gapdh, :Il2, :Hprt] )
    assert_equal(@x.subset_to_another(:naive, :percentile, needles, :hrs4), [34, 37, 43, 48] )

    needles = (80..100).map {|x| x}
    cols = {
      :naive => :percentile,
      :naive => :rank,
      :naive => :value,
      :hrs2 => :value,
      :hrs4 => :value
    }
    syms = @x.dps_to_symbols( @x.get_subset_dps(:naive, :percentile, needles) )
    assert_equal( @x.make_table(syms, cols), File.read("test/test_output.txt") )

    10.times do
      rank = [rand(17)+1]
      cond = [:naive, :hrs2, :hrs4, :hrs6, :hrs12][rand(5)]
      assert_equal( @x.get_subset_dps(cond, :rank, rank), [ @x.data[ @x.get_subset_ids(cond, :rank, rank)[0] ] ])
    end
  end
end