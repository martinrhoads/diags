module Diags
  module Node
    class Git < Diags::Node::Base
      GIT_CACHE_DIR = ::File.join(Diags::CACHE_DIR,'git')
      
      def initialize(origin,sha1)
#        super
        @origin = origin
        @sha1 = sha1
      end

      def go(directory=Diags::Utils::random_dir)

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

