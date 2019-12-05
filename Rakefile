require './run.rb'
require './config_module.rb'
require 'rake/hooks'

include ConfigModule
args = get_vars('config/util.conf')
filename = "#{args['data_dir']}/#{args['sfx_data']}"
summary_holdings = "#{args['data_dir']}/#{args['summary_holdings']}"

task :default=>[:full_update]

desc "Fetch summary holdings data."
task :fetch_dates do
  
  #`curl https://web.library.ualberta.ca/batchjobs/SFX/sfx2sirsi/batch.php > data/raw_sfx1`
  `php /home/sfxruby/threshold/sfx2sirsi/batch.php > data/raw_sfx1`
  filesize = File.new("data/raw_sfx1").size
  if  filesize < 500  
  STDERR.puts("Process aborted as the data/raw_sfx1 file size is too small. size: #{filesize}");
  exit(false)
  end  
  
   
  sh "./sed_dates.sh"
  `bundle exec ruby clean_summary_holdings.rb data/raw_sfx1`
end

desc "Fetch SFX data."
task :fetch_sfx do
  `bundle exec ruby fetch_sfx_data.rb`
   time_code=Time.now.to_s[2..9].gsub("-","")

   sh "sed 's@<controlfield tag=\"008\">#{time_code}uuuuuuuuuxx-uu-|------u|----|eng-d<\/controlfield>@<controlfield tag=\"008\">101010uuuuuuuuuxx-uu-|------u|----|eng-d<\/controlfield>@g' data/raw_sfxdata.xml > data/sfxdata.xml"   
end

desc "Full update."
task :full_update => [:fetch_dates, :fetch_sfx] do
  run=Run.new(File.open(filename), File.open(summary_holdings), "full")
end

desc "Nightly update."
task :nightly_update => [:fetch_dates, :fetch_sfx] do
  unless File.exists?("sfx-sirsi-full.txt") || File.exists?("sfx-sirsi-full.txt.old")
    run=Run.new(File.open(filename), File.open(summary_holdings), "incremental")
  end
end

desc "Full update (w/o fresh data)."
task :full_update_only do
  run=Run.new(File.open(filename), File.open(summary_holdings), "full")
end

desc "Nightly update (w/o fresh data)."
task :nightly_update_only do
  run=Run.new(File.open(filename), File.open(summary_holdings), "incremental")
end

desc "Copy serials admin files to proxy/htdocs"
task :copy_data do
  `cp data/badissn.txt /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/holderr.txt /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/matchissn.txt /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/notSFX.txt /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/notSIR /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/summary_holdings /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/targets.txt /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi/`
  `cp data/sfx-sirsi* /exlibris/sfx_ver/sfx4_1/proxy/htdocs/sfx2sirsi`
end

desc "Run all tests."
task :tests do
  ruby "tests/config_module_test.rb"
  ruby "tests/run_test.rb"
  ruby "tests/sfx2sirsi_test.rb"
  ruby "tests/sirsi_record_test.rb"
  ruby "tests/summary_holdings_test.rb"
end

#set flag and remove data files before running updates 
before :full_update, :nightly_update, :full_update_only, :nightly_update_only do
  File.open("data/running", "w"){ |file| file.puts Time.now }
  File.delete "data/sfx-sirsi-full.txt" if File.exists? "data/sfx-sirsi-full.txt"
  File.delete "data/sfx-sirsi-incremental.txt" if File.exists? "data/sfx-sirsi-incremental.txt"
  File.delete "data/raw_sfxdata.xml" if File.exists? "data/raw_sfxdata.xml"
end

after :full_update, :nightly_update, :full_update_only, :nightly_update_only do
  File.delete "data/running" if File.exists? "data/running"
end
