require 'test/unit'
require 'stringio'
require './config_module.rb'

class ConfigModuleTest < Test::Unit::TestCase
  include ConfigModule

  def setup
    @conf=StringIO.new %{"a=b"\n"test"="this_test"}
  end

  def test_process_vars
    vars = {}
    vars = process_vars(@conf)
    assert_equal("b", vars["a"])  
    assert_equal("this_test", vars["test"])
  end

end
