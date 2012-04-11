module Diags
  module Utils

    def random_file
      file = File.join(Diags::TEMP_DIR,'file-' + rand(9999).to_s)
      FileUtils.touch file
      file
    end

    def random_dir
      dir = File.join(Diags::TEMP_DIR,'dir-' + rand(9999).to_s)
      Dir.mkdir dir
      dir
    end

    def sudo_mkdir(dir)
      # TODO: decide how to handle the automatic creation of shit compared to prompting user 
      begin
        FileUtils.mkdir_p dir
      rescue ::Errno::EACCES
        command = "sudo mkdir #{dir} && sudo chown #{Diags::USER} #{} && chmod go+w #{dir}"
        raise "Could not create cache dir. Command was '#{command}'" unless system command
      end
      
    end
  end
end
