my_dir = File.dirname __FILE__
require File.join(my_dir,'driver')


set :environment, :test
#set :app_file, File.join(root, 'cloudscaling','driver.rb')
#disable :run

configure :test do
  enable :logging, :dump_errors, :raise_errors
end

set :raise_errors, true


run DiagsServer
