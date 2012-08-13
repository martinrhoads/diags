#require_relative './driver'
my_dir = File.dirname __FILE__


set :environment, :development
set :root,  root
set :app_file, File.join(root, 'lordevents.rb')
disable :run

configure :development do
  enable :logging, :dump_errors, :raise_errors
end

require File.join(my_dir,'driver')

run DiagsServer

