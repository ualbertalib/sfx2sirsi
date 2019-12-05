require 'test/unit'
require './sfx2sirsi.rb'

class TestSymphonyRecords < Test::Unit::TestCase

  def setup
    file_handle = File.open("tests/test-data/single_sfx.xml")
    summary_holdings = File.open("tests/test-data/summary_holdings")
    @sfx2sirsi = Sfx2Sirsi.new({
      :file=>file_handle,
      :summary_holdings=>summary_holdings,
      :mode=>"full"})
    file_handle.close
  end

  # .new
  def test_sfx2sirsi_is_an_object
    assert_not_nil @sfx2sirsi
  end

  # .hash_list
  def test_hash_list_not_empty
    assert_not_nil @sfx2sirsi.hash_list
    assert_not_equal(0, @sfx2sirsi.hash_list.size)
  end

  #.summary_holdings
  def test_summary_holdings_not_empty
    assert_not_nil @sfx2sirsi.summary_holdings
    assert_not_equal(0, @sfx2sirsi.summary_holdings.size)
    assert_equal "v.1 (1990)-", @sfx2sirsi.summary_holdings["55555"][:summary_holdings]
  end

end
