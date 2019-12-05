require 'test/unit'
require './run.rb'
require 'digest/sha1'

class RunTest < Test::Unit::TestCase

  def setup
    @run = Run.new(File.open("tests/test-data/single_sfx.xml"), File.open("tests/test-data/summary_holdings"), "full")
  end

  # .new
  def test_run_is_an_object
    assert_not_nil @run
  end

  # .write_hash_file
  def test_write_hash_file
    hash_file_name = "tests/test-data/hash"
    hash = {}
    this_hash = {}
    if File.exists? hash_file_name then File.delete hash_file_name end
    hash["55555"] = "b438389e7628968c95c0126b9fd3253d975f91d6"
    @run.write_hash_file("tests/test-data", hash)
     
    assert File.exists?(hash_file_name), "File does not exist."
  end

end
