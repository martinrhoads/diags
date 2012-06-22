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


run "cd #{deb_dir} && fpm --gem-bin-path /usr/local/bin --gem-gem /usr/local/bin/gem -s gem -t deb bundler"

%w{cs-python-libs}.each do |package|
  options = read_file("#{package}.rb")
  options['repo'] = Diags::Node::Git.new options
  package_object = Diags::Node::PackageFile.new options
  package_object.set_state File.join(deb_dir,package)
end
