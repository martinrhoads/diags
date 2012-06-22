file = File.expand_path __FILE__

diags_dir = File.dirname File.dirname file
diags_lib = File.join(diags_dir,'lib/diags')

cloudscaling_dir = File.dirname file
deb_dir = File.join cloudscaling_dir, 'debs'

require diags_lib
Dir.chdir cloudscaling_dir

def read_file(file)
  eval File.read(file).gsub(/\n/,'')
end

FileUtils.rm_rf deb_dir
FileUtils.mkdir_p deb_dir

# build kyotocabinet, zeromq, and ruby
%w{ kyotocabinet zeromq ruby1.9.2-1}.each do |package|
  options = read_file("#{package}.rb")
  repo_object = Diags::Node::Git.new options
  options['repo'] = repo_object
  package_object = Diags::Node::PackageDir.new options
  options['package_dependency'] = package_object
  fpm_object = Diags::Node::FPM.new options
  deb = fpm_object.set_state
  FileUtils.cp(deb,File.join('debs',fpm_object.filename))
  puts "made deb at #{fpm_object.filename}"
end

# TODO: something better
run "cd #{deb_dir} && fpm --gem-bin-path /usr/local/bin --gem-gem /usr/local/bin/gem -s gem -t deb bundler" \
  unless File.exists?('debs/rubygem-bundler_1.1.4_all.deb')

# build cs-python-libs
%w{cs-python-libs}.each do |package|
  options = read_file("#{package}.rb")
  options['repo'] = Diags::Node::Git.new options
  package_object = Diags::Node::PackageFile.new options
  package_object.set_state File.join(deb_dir,package)
end


# build substratum
substratum_options = read_file('substratum.rb')
substratum_options['package_dependency'] = Diags::Node::PackageSubstratum.new(substratum_options)
substratum_fpm_object = Diags::Node::FPM.new(substratum_options)
deb = substratum_fpm_object.set_state
FileUtils.cp(deb,File.join('debs',substratum_fpm_object.filename))


# build mini-boot
miniboot_options = read_file('mini-boot.rb')
miniboot_options['repo'] = Diags::Node::Git.new(miniboot_options)
miniboot_options['package_object'] = Diags::Node::PackageFile.new(miniboot_options)
destination_file = File.join(random_dir,'srv/substratum/services/tftproot/images',miniboot_options['build_artifact'])

FileUtils.mkdir_p File.dirname(destination_file)
miniboot_options['package_object'].set_state destination_file
# TODO: something better than this:
run "sudo cp /boot/vmlinuz-#{`uname -r`.chomp} #{File.dirname(destination_file)}"


miniboot_options['package_dependency'] = Diags::Node::PackageDir.new miniboot_options
miniboot_fpm_object = Diags::Node::FPM.new miniboot_options
miniboot_deb = miniboot_fpm_object.set_state
FileUtils.cp(miniboot_deb,File.join('debs',miniboot_fpm_object.filename))

STDERR.puts "destination_file is #{destination_file}"
