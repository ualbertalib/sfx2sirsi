require './config_module.rb'
require './sfx2sirsi.rb'

class Run
  include ConfigModule

  def initialize(file, summary_holdings, mode)
    @args = get_vars('config/util.conf')
    sfx2sirsi = Sfx2Sirsi.new({:file=>file, :summary_holdings=>summary_holdings, :mode=>mode})
    write_hash_file(@args['data_dir'], sfx2sirsi.hash_list)
  end

  def write_hash_file(location, hash_list) # write list of md5 hashes from the current run (for comparison in next run)
    begin
      f = File.open("#{location}/#{@args['hashes']}", "w")
      hash_list.each do |key,value|
        f.puts "#{key}: #{value}"
      end
      f.close
    rescue
      raise "Unable to open hash file."
      exit
    end
  end
end
