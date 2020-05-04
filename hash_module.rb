require 'digest/sha1'

module HashModule
 def create_hashes
    @sfx_records.each do |record|
      sfx_object_id = record['090']['a'] if record['090']
      #puts "object_id = #{sfx_object_id}"
      @hash_list[sfx_object_id]=Digest::SHA1::hexdigest(record.to_s)  #create md5 hash out of each sfx record 
    end
  end

  def read_previous_hashes
    begin
      File.open("#{@args['data_dir']}/#{@args['hashes']}").each_line do |line|
        @previous_hash_list[line.split(":").first.strip]=line.split(":").last.strip  #read the md5 hashes of the previous run
      end
    rescue
      raise "#{caller}: unable to open hash file."
    end
  end

  def hashes_have_changed
    !@hash_list.eql? @previous_hash_list  # compare current and previous md5 hashes to see if records have changed
  end
end
