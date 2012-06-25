module Diags
  module Node
    class Git < Diags::Node::Base
      
      def initialize(opts)
        @origin = opts['origin']
        raise "you need to specify either a sha1 or a branch" unless opts.include?('sha1') ^ opts.include?('branch')
        if opts['sha1']
          @sha1 = opts['sha1']
        else
          @sha1 = `git ls-remote #{opts['origin']} | grep refs/heads/#{opts['branch']} | awk '{print $1}'`.chomp
          raise "could not find branch #{opts['branch']} on remote #{opts['origin']}" if @sha1.empty?
        end
      end


      def set_state(directory=Diags::Utils::random_ramfs)
        go directory
      end
      

      def go(directory=Diags::Utils::random_ramfs)

        raise "DirectoryDoesNotExist" unless Dir.exists? directory
        if check_repo_for_commit(GIT_CACHE_DIR,@sha1)
          logger.info "found commit locally"
          reset_directory(directory,@sha1)
        else 
          run "git --git-dir=#{GIT_CACHE_DIR} fetch --force  #{@origin} refs/heads/*:refs/remotes/origin/*"
          raise "could not find commit " unless check_repo_for_commit(@origin,@sha1)
          logger.info "got commit from origin"
          reset_directory(directory,@sha1)
        end
        directory
      end

      def check_repo_for_commit(repo,sha1)
        logger.debug "checking for commit #{sha1} in #{repo}"
        system "git --git-dir=/var/tmp/diags/git branch --contains #{sha1} >> /dev/null 2>&1 "
      end

      def state
        @sha1
      end

      private 

      def reset_directory(directory,sha1)
        run "git --git-dir=#{GIT_CACHE_DIR} --work-tree=#{directory} clean -fd"
        run "git --git-dir=#{GIT_CACHE_DIR} --work-tree=#{directory} reset --hard #{sha1}"
      end
    end
  end
end

