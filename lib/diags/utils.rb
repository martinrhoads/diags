module Diags
  module Utils

    
    def logger
      Diags::Utils.logger
    end
    

    # Global, memoized, lazy initialized instance of a logger
    def self.logger
      @logger ||= Logger.new(STDERR)
    end


    def run(command,directory=nil)
      #TODO: decide if this is right 
      Diags::Utils::logger.info "running : '#{command}'" 
      begin
        formatted_command = ''
        formatted_command << "cd #{directory} && " if defined? directory
        formatted_command << command.gsub(/#.*$/,'') # remove any comments
        output = `bash -cex '#{formatted_command}'`.chomp
      rescue Object => o
        STDERR.puts "error caught"
        STDERR.puts "output was:"
        STDERR.puts output
        raise o
      end
      raise "running #{command} failed with: \n#{output}" unless $?.success?
      output
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
      run "sudo chown $USER:$USER #{dir}"
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

    def make_chrootable(directory)
      %w{proc dev sys}.each {|dir| run "sudo mkdir -p #{File.join(directory,dir)}"}  
      run "sudo mount -t proc none #{directory}/proc"
      run "sudo mount --bind /dev #{directory}/dev"
      run "sudo mount sysfs -t sysfs #{directory}/sys"
      run "sudo mount -t devpts none #{directory}/dev/pts"
    end

    def undo_make_chrootable(directory)
      run "sudo umount -lf #{directory}/dev/pts"
      run "sudo umount -lf #{directory}/proc"
      run "sudo umount -lf #{directory}/dev"
      run "sudo umount -lf #{directory}/sys"
    end
    
    
  end
end
