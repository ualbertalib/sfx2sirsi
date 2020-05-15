require 'nokogiri'
require 'open-uri'
require './config_module.rb'
require './summary_holdings.rb'

class SirsiRecord
  include ConfigModule
  include SummaryHoldings

  attr_accessor :object_id, :issnPrint, :issnElectronic, :summaryHoldings, :free_or_restricted

  def initialize(fields={})
    @args = get_vars('config/util.conf')
    @object_id = fields[:object_id]
    @issnPrint = fields[:issnPrint] || ""
    @issnElectronic = fields[:issnElectronic] || ""
    @summaryHoldings = fields[:summaryHoldings]   
    @previousTitle = @laterTitle = ""
    @free_or_restricted = fields[:free_or_restricted]
  end

  def to_s
    "#{object_id}|#{open_url}|#{clean_summaryHoldings}|#{related_objects?}" unless summaryHoldings=="-PROBLEM RECORD-"
  end

  private

  def issn
    issn = ""
    if issnPrint == ""
      issn = issnElectronic
    else
      issn = issnPrint
    end
    issn
  end

  def open_url  
    "http://resolver.library.ualberta.ca/resolver?ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_ver=Z39.88-2004&rfr_id=info%3Asid%2Fualberta.ca%3Aopac&rft.genre=journal&rft.object_id=#{object_id}&rft.issn=#{issn}&rft.eissn=#{issnElectronic}&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004"
  end

  def related_objects?
    @previousTitle!="" #|| @laterTitle!=""
  end

  def get_title(record)
    record.xpath("sirsi:text", 'sirsi'=>"http://schemas.sirsidynix.com/symws/standard").text
  end

  def get_catkey(issns=[])
    catkey=""
    begin
      File.open("#{@args['data_dir']}/#{@args['matchissn']}").each_line do |line|
        split_record = line.split("|")
        if issns.include? split_record[2].strip.downcase then 
          catkey = split_record.first
        end
      end
    rescue
      raise "#{caller}: Unable to open matchissn."
    end
    catkey
  end

  def temp_summaryHoldings  #not used - can be deleted
    startDate = summaryHoldings.split("-").first

    if summaryHoldings.split("-").size == 1 then
      endDate=""
    else
      endDate = summaryHoldings.split("-").last
    end

    unless startDate.nil?
      startDate = startDate.split("(").last.gsub(")", "").strip if startDate
    end
    unless endDate.nil? || endDate==""
      endDate=endDate.split("(").last.gsub(")", "").strip if endDate
    end
    "#{startDate}-#{endDate}"
  end

  def regex_summaryHoldings
    puts summaryHoldings
    years = summaryHoldings.select{|i| i[/\d{4}/]}
    statement = summaryHoldings.include?("-") ? summaryHoldings.split("-")[1] : summaryHoldings
    #puts years

    if years.empty?
      return statement
    else
      #statement.gsub!(/\(\d{4}\)/, "only") if statement
      if summaryHoldings.end_with?("-")
        return "#{years[0]}-" if years.size == 1
        return "#{years[0]},#{years[1]}-" if years.size == 2
        return "#{years[0]}-#{years[1]}, #{years[2]}-" if years.size==3
        return "#{years[0]}-#{years[1]}, #{years[2]}-#{years[3]}, #{years[4]}-" if years.size==5
      else
        return "#{years[0]} #{statement.strip}" if (years.size==1 and statement.include?("only"))
        return "#{years[0]}- #{statement.strip}" if (years.size==1 and !statement.include?("only"))
        return "#{years[0]}-#{years[1]}" if years.size==2
        return "#{years[0]}, #{years[1]}-#{years[2]}" if years.size==3
        return "#{years[0]}-#{years[1]}, #{years[2]}-#{years[3]}" if years.size==4
        return "#{years[0]}, #{years[1]} - #{years[2]}, #{years[3]}-#{years[4]}" if years.size==5
        return "#{years[0]}-#{years[1]}, #{years[2]}-#{years[3]}, #{years[4]}-#{years[5]}" if years.size==6
      end
    end

  end

  def clean_summaryHoldings
    summaryHoldings == "Available" ? "Available" : pretty_print(merge(compile(summaryHoldings)))
  end
end

