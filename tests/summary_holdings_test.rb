require "test/unit"
require "./clean_summary_holdings"

class SummaryHoldingsTest < Test::Unit::TestCase

  def test_holdings_is_an_object
    summary_holdings = SummaryHoldings.new("tests/test-data/raw_sfx1", "tests/test-data/summary_holdings_output_test")
    assert_not_nil summary_holdings
  end

  def test_summary_holdings_file_created
    File.delete "tests/test-data/summary_holdings_output_test" if File.exists? "tests/test-data/summary_holdings_output_test"
    summary_holdings = SummaryHoldings.new("tests/test-data/raw_sfx1", "tests/test-data/summary_holdings_output_test")
    assert File.exists?("tests/test-data/summary_holdings"), "summary_holdings file not created."
  end

  def test_summary_holdings_file_contents
    summary_holdings_json = '{"954921332001"=>{:summary_holdings=>"(1990)-", :free=>"free"}, "954921332003"=>{:summary_holdings=>"v.1(1958)-", :free=>nil}, "954921332004"=>{:summary_holdings=>"(1987)-", :free=>nil}, "954921333005"=>{:summary_holdings=>"(1965)-", :free=>nil}, "954921333007"=>{:summary_holdings=>"(1963)-", :free=>nil}, "954921333008"=>{:summary_holdings=>"(1994) - (2010)", :free=>nil}}'.gsub(/\s+/, "")
    summary_holdings = SummaryHoldings.new("tests/test-data/raw_sfx1", "tests/test-data/summary_holdings_output_test")
    assert_equal summary_holdings_json, summary_holdings.instance_variable_get(:@records_hash).to_s.gsub(/\s+/, "")
  end
 
  
end
