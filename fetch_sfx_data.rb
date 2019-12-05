require 'open-uri'
require './config_module.rb'

include ConfigModule

args = get_vars('config/util.conf')

sfx_data_uri = "#{args['sfx_data_path']}"
begin 
  f=File.new("#{args['data_dir']}/#{args['raw_sfx']}", "w")
rescue
  raise "#{caller}: Unable to open output file."
  exit
end
begin
  f.puts open(sfx_data_uri).read
rescue
  raise "#{caller}: Unable to open sfx url."
  exit
end
f.close

