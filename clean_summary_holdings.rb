require "./config_module"

#This script cleans up the summary_holdings data that I pull down from Jeremy's PHP script
#The test for this class currently tests against production data. It should be refactored to test against test data.


class SummaryHoldings
  include ConfigModule

  def initialize(infile_location, outfile_location)
    @args = get_vars('config/util.conf')
    of = create_output_file(outfile_location)
    of.puts process_records(infile_location)
    of.close
  end

  private

  def create_output_file(outfile)
    begin
      of = File.open(outfile, "w")
    rescue
      raise "#{caller}: Unable to open output file."
    end
    of
  end

  def process_records(infile_location)
    records = read_input_file(infile_location).split("<line>")
    records.delete_at(0)
    @records_hash = {}
    records.each do |record|
      construct_record_hash record
    end
    @records_hash
  end

  def construct_record_hash(record)
    split_record = record.gsub("\n", "").split("^^")
    object_id = split_record[1]
    summary_holdings = split_record[2].gsub(" -- ", "").strip if split_record[2]
    if split_record[3] then
      free = "free" if split_record[3].strip == "[IS_FREE]"
    end
    if object_id then
      @records_hash[object_id] = {:summary_holdings=>summary_holdings, :free=>free} unless summary_holdings == " -- " #This conditional covers nil dates.
    end
  end

  def read_input_file(infile_location)
    file_contents = []
    begin
      file_contents = File.read(infile_location)

    rescue
      raise "Unable to open raw sfx1 data."
      exit
    end 
    file_contents
  end
end

holdings = SummaryHoldings.new("data/raw_sfx1", "data/summary_holdings")
