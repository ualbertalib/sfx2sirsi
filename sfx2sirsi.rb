require './sirsi_record.rb'
require './config_module.rb'
require './hash_module.rb'
require 'open-uri'
require 'nokogiri'
require 'marc'

class Sfx2Sirsi
  include ConfigModule
  include HashModule

  attr_reader :summary_holdings, :hash_list

  def initialize(options={})
    sfxfile = options[:file]
    puts File.basename(options[:summary_holdings].path)
    summary_holdings_file = options[:summary_holdings]
    mode = options[:mode]
    @args = get_vars('config/util.conf')   
    initialize_arrays
    process_records(sfxfile, summary_holdings_file, mode)
  end

  private

  def process_records(sfxfile, summary_holdings, mode)

    read_marc_records(sfxfile)
    create_hashes    # create md5 hashes to tell if records have changed

    read_previous_hashes if mode=="incremental"
    if mode=="full" || hashes_have_changed then 
      update_records(summary_holdings, mode)  # update records only if full update specified, or records have changed
    else
      puts "records unchanged"
      exit  # do nothing if records haven't changed
    end
  end

  def initialize_arrays
    @sfx_records = []
    @hash_list = {}
    @previous_hash_list = {}
    @summary_holdings = {}
  end

  def update_records(summary_holdings, mode)
    get_summary_holdings(summary_holdings)
    create_sirsi_records(mode)
  end

  def read_marc_records(sfxfile)
    reader = MARC::XMLReader.new(sfxfile)
    for record in reader
      @sfx_records << record
    end
  end

  def get_summary_holdings(summary_holdings)
    @summary_holdings = eval(summary_holdings.read)
  end

  def create_sirsi_records(mode)
    mode_file = "sirsi_#{mode}"
    begin 
      of = File.open("#{@args['data_dir']}/#{@args[mode_file]}", "w")
    rescue
      raise "#{caller}: Error opening output file."
      exit
    end

    begin
      target_file = File.open("#{@args['data_dir']}/#{@args['target_file']}", "w")
    rescue
      raise "#{caller}: Error opening target file."
      exit
    end

    @sfx_records.each do |marc_record|
      puts marc_record['090']['a'] if marc_record['090']
      puts "processing..."
      write_sirsi_record_to_file(marc_record, of)
      write_targets_to_file(marc_record, target_file)
    end 
    
    of.close
  end

  def write_sirsi_record_to_file(marc_record, of)
    sfx_object_id = marc_record['090']['a'] if marc_record['090']
    if @hash_list[sfx_object_id] != @previous_hash_list[sfx_object_id] then
      print_issn = marc_record['022']['a'] if marc_record['022']
      electronic_issn = marc_record['776']['x'] if marc_record['776'] 
      of.puts create_sirsi_record(sfx_object_id, print_issn, electronic_issn)
    end
  end

  def write_targets_to_file(marc_record, target_file)
    target_list = []
    sfx_object_id = marc_record['090']['a'] if marc_record['090']
    title = marc_record['245']['a'] if marc_record['245']
    #if @hash_list[sfx_object_id] != @previous_hash_list[sfx_object_id] then
      if marc_record['866'] then
        tgts = marc_record.find_all{|t| ('866') === t.tag}
        tgts.each{|t| target_list << t['x'].to_s}
        target_list.join(", ")
      else 
        target_list << "No targets"
      end
      target_file.puts "#{sfx_object_id} | #{title}: #{target_list}"
    #end
  end

  def create_sirsi_record(sfx_object_id, issnPrint, issnElectronic)
    if @summary_holdings.has_key? sfx_object_id then # if Jeremy's script doesn't include a record, then it is skipped here.
      holdings = @summary_holdings[sfx_object_id]
    #  free = "restricted" || holdings[:free]
      @sirsi_record = SirsiRecord.new({
        :object_id=>sfx_object_id,
        #:issnPrint=>issnPrint,
        #:issnElectronic=>issnElectronic,
        :summaryHoldings => holdings[:summary_holdings]})
        #:free_or_restricted=>free})
    else
     # free = "restricted" || holdings[:free]
      @sirsi_record = SirsiRecord.new({
        :object_id=>sfx_object_id,
        #:issnPrint=>issnPrint,
        #:issnElectronic=>issnElectronic,
        :summaryHoldings => "Available"})
        #:free_or_restricted=>free})
    end
    @sirsi_record.to_s
  end
end
