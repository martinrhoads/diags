#!/usr/bin/env ruby


file = File.expand_path __FILE__
diags_dir = File.dirname File.dirname file
diags_lib = File.join(diags_dir,'lib/diags')
cloudscaling_dir = File.dirname file
deb_dir = File.join cloudscaling_dir, 'debs'


require diags_lib
Dir.chdir cloudscaling_dir


FileUtils.rm_rf deb_dir
FileUtils.mkdir_p deb_dir


# read build description file
raise "could not find config file" unless project = eval(File.read('all.rb'))


# iterate through package build
project.each do |name,config|
  config.merge!({'name'=>name})
  puts "building: #{name}"
  case config['type']


  when "PackageDir"
    repo_object = Diags::Node::Git.new config
    config['repo'] = repo_object
    package_object = Diags::Node::PackageDir.new config
    config['package_dependency'] = package_object
    fpm_object = Diags::Node::FPM.new config
    deb = fpm_object.set_state
    FileUtils.cp(deb,File.join('debs',fpm_object.filename))
    puts "made deb at #{fpm_object.filename}"
  when "PackageFile"
    config['repo'] = Diags::Node::Git.new config
    package_object = Diags::Node::PackageFile.new config
    package_object.set_state File.join(deb_dir,"#{name}.deb")
  when "PackageMiniboot"
    config['repo'] = Diags::Node::Git.new(config)
    config['package_object'] = Diags::Node::PackageFile.new(config)
    destination_file = File.join(random_dir,'srv/substratum/services/tftproot/images',config['build_artifact'])
    FileUtils.mkdir_p File.dirname(destination_file)
    config['package_object'].set_state destination_file
    # TODO: something better than this:
    run "sudo cp /boot/vmlinuz-#{`uname -r`.chomp} #{File.dirname(destination_file)}"
    config['package_dependency'] = Diags::Node::PackageDir.new config
    miniboot_fpm_object = Diags::Node::FPM.new config
    miniboot_deb = miniboot_fpm_object.set_state
    FileUtils.cp(miniboot_deb,File.join('debs',miniboot_fpm_object.filename))
  when "PackageSubstratum"
    config['package_dependency'] = Diags::Node::PackageSubstratum.new(config)
    substratum_fpm_object = Diags::Node::FPM.new(config)
    deb = substratum_fpm_object.set_state
    FileUtils.cp(deb,File.join('debs',substratum_fpm_object.filename))
  else
    STDERR.puts "    unknown type"
    STDERR.puts "could not determine type for #{name}"
    STDERR.puts "config:\n#{config}"
    raise "could not determine type for #{name}"
  end
end


STDERR.puts "end of testing..."
STDERR.puts "destination_file is #{destination_file}"
