require 'test/unit'
require './sirsi_record.rb'

class TestSirsiRecord < Test::Unit::TestCase
  def setup
    @sirsi_record=SirsiRecord.new({
      :object_id=>"9999999",
      :issnPrint=>"0001-4273",
      :issnElectronic=>"0000-0000",
      :summaryHoldings=>"Full Run",
      :free_or_restricted=>"restricted"})  

  end

  # .new
  def test_record_not_nil
    assert_not_nil @sirsi_record
  end

  # getters
  def test_attribute_values
    assert_equal "9999999", @sirsi_record.object_id
    assert_equal "0001-4273", @sirsi_record.issnPrint
    assert_equal "0000-0000", @sirsi_record.issnElectronic
    assert_equal "Full Run", @sirsi_record.summaryHoldings
  end

  # .to_s
  def test_record_returns_correct_string
    assert_equal '9999999|0001-4273|0000-0000|http://resolver.library.ualberta.ca/resolver?ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_ver=Z39.88-2004&rfr_id=info%3Asid%2Fualberta.ca%3Aopac&rft.genre=journal&rft.issn=0001-4273&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004|Full Run-|false|restricted', @sirsi_record.to_s
  end

end
