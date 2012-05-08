module Diags
  module Utils

    
    def logger
      Diags::Utils.logger
    end
    

    # Global, memoized, lazy initialized instance of a logger
    def self.logger
      @logger ||= Logger.new(STDERR)
    end


    def run(command)
      Diags::Utils::logger.info "running : '#{command}'" 
      begin
        output = `#{command}`
      rescue Object => o
        STDERR.puts "error caught"
        STDERR.puts "output was: \n" + output
        raise o
      end
      raise "running #{command} failed with: \n#{output}" unless $?.success?
      $?.success?
    end
    

    def random_file
      file = File.join(Diags::TEMP_DIR,'file-' + rand(999999).to_s)
      FileUtils.touch file
      file
    end

    def random_dir
      dir = File.join(Diags::TEMP_DIR,'dir-' + rand(999999).to_s)
      Dir.mkdir dir
      dir
    end

    def random_ramfs
      dir = random_dir
      run "sudo mount -t ramfs size=20m #{dir}"
      dir
    end

    def unmount(path)
      run "sudo umount -l #{path} "
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
