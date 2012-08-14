#!/usr/bin/env ruby


require 'thread'
require 'logger'
require 'sinatra'


file = File.expand_path __FILE__
diags_dir = File.dirname File.dirname file
diags_lib = File.join(diags_dir,'lib/diags')
cloudscaling_dir = File.dirname file
@@public_dir = File.join(cloudscaling_dir,'public')
@@deb_dir = File.join cloudscaling_dir, 'debs'
public_ip = `ifconfig eth1 | grep 'inet addr:' | awk '{print $2}' | cut -d : -f 2`.strip
@@port = '4567'
@@jobs = []
@@mutex = Mutex.new
@@current_job = nil
@@completed_steps = 0
use Rack::Logger
@@log = Logger.new(STDERR)
@@log.level = Logger::DEBUG

require diags_lib
Dir.chdir cloudscaling_dir


# FileUtils.rm_rf @@deb_dir
# FileUtils.mkdir_p @@deb_dir


# read build description file
#raw_file = File.read('all.rb')
#project = eval raw_file
#md5 = Digest::MD5.hexdigest(raw_file)


class DiagsServer < Sinatra::Base


  @@incoming_file = <<EOF
Name: default
IncomingDir: /srv/apt_incoming
TempDir: /tmp
Allow: lucid maverick natty
EOF
  
  @@pulls_file = <<EOF
Name: natty
From: natty
Components: main universe multiverse
EOF

  @@distributions_file = <<EOF
Origin: apt.cloudscaling.com
Label: apt repository lucid
Codename: lucid
Architectures: amd64 i386
Components: main universe multiverse
Description: Cloudscaling APT repository
SignWith: apt@cloudscaling.com
Pull: lucid

Origin: apt.cloudscaling.com
Label: apt repository maverick
Codename: maverick
Architectures: amd64 i386
Components: main universe multiverse
Description: Cloudscaling APT repository
SignWith: apt@cloudscaling.com
Pull: maverick

Origin: apt.cloudscaling.com
Label: apt repository natty
Codename: natty
Architectures: amd64 i386
Components: main universe multiverse
Description: Cloudscaling APT repository
SignWith: apt@cloudscaling.com

Origin: apt.cloudscaling.com
Label: apt repository precise
Codename: precise
Architectures: amd64 i386
Components: main universe multiverse
Description: Cloudscaling APT repository
SignWith: apt@cloudscaling.com
EOF

  @@options_file = <<EOF
gnupghome /etc/diags/gnupg
EOF
  
  
  @@key_file = <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.10 (GNU/Linux)

mQENBE4jlOUBCACWtyx4DAc/nYl3tp0rLdsYDBWEgVnUEgRitJE/qvNbAhob5t6n
FHlQ6vO2G3DBGVIpZxDHfgXuMLdhi974nNGMQHD3yQaGd9YkYv9jcH954pLXdt4e
lOiitJ2jxIQQv9ernZWvTKQAQ4JzdF9SQ2nwT81r0wiIhJKAsqGolny/wJoPtcWP
2ZuE2/J6DurlDmrH42YpmzNyzfEF3TJi2mG5Xm6vJA4fpEvd+wVHF41X0OAU4Xnf
DKCeepolu9UFhBCjrGXxgj1Wx76TdfaV9MfezV9eycscsd6lrhW2nCN8NCUgXz5u
+3/GzjBnQAJ3JZzKphWUtSZIRsnwHSiViOLzABEBAAG0MkNsb3Vkc2NhbGluZyBB
UFQgUmVwb3NpdG9yeSA8YXB0QGNsb3Vkc2NhbGluZy5jb20+iQE4BBMBAgAiBQJO
I5TlAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRAg2QoUJ8j7COA7B/0X
jScRphbn3rM8NLEGTqnoHhv9QyD3XUKI3l4B5tT2CGuxk1DYJ5d0da1mUC3riMuy
0ZF6UOnwImBB+paXsQNCrikoYCxvO+RGm1dJ5XN3+12yP4lqHdF8083so9aTrloZ
ThjOcS3qjKgI/vyhzLYQNAA9xPAGyVsXc7PNFx/3U3XVU9sNfBuwH4Allfu21Pcf
YQvgz1Ne7ZsQgDdTRgxAm/m1hfYJdJqIHjeeG9N/PNkQ3IddHZjhiSM1/FrLPxvR
6KVppNwBSYk4yGOT+g6T1nOH/oav+V6ZusiJwrD60RqSKLI9x5Jutz9I2Q7bXxsZ
MdKvdW/pnjXwnJRwdK24uQENBE4jlOUBCACzbt2gPuYJ8bLO6dykzFN9F6geHQjB
Do6+zyZmwyhBq0va5MgHbv4EBj/AGu6ap6GTB7DZPlJ10Mx5GydrlylUNORz6PQf
nboeMVebGbcu+h7x+GI4sAMClIhP2y3AHU9g7tGJPvFZc3YiUcA6lp82NHKOhhRZ
lM0klXPmHcUxMeA6tgBLQ4Ylq5XAQ4mW2bGHRixMF6PIM13muN7s79WPpa+/3LXm
s/O7PCpnzb0AqNr6KTAzp402fIkNbIsOfzkPgJkMmsHA5UIQvWZGLXTtMsDSw3qC
b3qOyJaz3YI8dI+D7PgiUPXYA5UW69N72Ibq2pPOZpBfGltM958Kb/sDABEBAAGJ
AR8EGAECAAkFAk4jlOUCGwwACgkQINkKFCfI+wj7dQf+O4IHRsFUCapvATGGk1CT
Uiel9ShiutLLUmJ7WyD7Ry3FgsDej2oGqk+pG1jX64uyPIgNGz50SFeoWG4SnOlx
4E5RD1sCCLU9KRO9qdqcUq9vF7Ci5iFK4bHNsXrkaWrH0iGZi1EXxQD/i2V3Zg//
iyigTOe57pQCE7GC2aKTHrNsHD9Efz+ijNBrPZZz2Slw3rT8QfZqsaF6vHCNA7HA
V1O68KFvm7dmkrMc92QLAOzfA87dXH1Yud1gjkbI7ciGheHejissEcT0CROvrJqV
uS8NmH0Gnw7TQ+ywDAAZ4UoxOFrva/JyAsm2SGSqez1vmQRzbcxUUle0vq2kPAN2
AA==
=lspr
-----END PGP PUBLIC KEY BLOCK-----
EOF


  def build_project(project)
    @@log.debug "building project"
    project.each do |name,config|
      @@log.debug "starting build for #{name}..."
      config.merge!({'name'=>name})
      puts "building: #{name}"
      puts "config is: #{config.inspect}"
      case config['type']
      when "PackageDir"
        @@log.debug "build PackageDir type" 
        repo_object = Diags::Node::Git.new config
        config['repo'] = repo_object
        package_object = Diags::Node::PackageDir.new config
        config['package_dependency'] = package_object
        fpm_object = Diags::Node::FPM.new config
        deb = fpm_object.set_state
        FileUtils.cp(deb,File.join('debs',fpm_object.filename))
        puts "made deb at #{fpm_object.filename}"
      when "PackageFile"
        @@log.debug "build PackageFile type" 
        config['repo'] = Diags::Node::Git.new config
        package_object = Diags::Node::PackageFile.new config
        STDERR.puts "name is #{name}"
        STDERR.puts "@@deb_dir is #{@@deb_dir}"
        package_object.set_state File.join(@@deb_dir,"#{name}.deb")
      when "PackageMiniboot"
        @@log.debug "build PackageMiniboot type" 
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
        @@log.debug "build PackageSubstratum type" 
        config['package_dependency'] = Diags::Node::PackageSubstratum.new(config)
        substratum_fpm_object = Diags::Node::FPM.new(config)
        deb = substratum_fpm_object.set_state
        FileUtils.cp(deb,File.join('debs',substratum_fpm_object.filename))
      else
        @@log.error "unknown type"
        STDERR.puts "    unknown type"
        STDERR.puts "could not determine type for #{name}"
        STDERR.puts "config:\n#{config}"
        raise "could not determine type for #{name}"
      end
      @@completed_steps += 1
    end 
  end
  
  def deploy_project(destination,original_json) 
    conf_dir = File.join(destination,'conf')
    FileUtils.rm_rf destination
    FileUtils.mkdir_p conf_dir
    %w{distributions incoming pulls options}.each do |file|
      File.open(File.join(conf_dir,file), 'w') {|f| f.write(eval "@@#{file}_file") }
    end
    File.open(File.join(conf_dir,'apt@cloudscaling.com.gpg.key'), 'w') {|f| f.write(@@key_file) }
    `/usr/bin/reprepro --noskipold -Vb #{destination} includedeb precise debs/*.deb`
    raise "could not build repo" unless $?.success?
    FileUtils.touch File.join(destination,'.done')
    File.open(File.join(destination,'build'), 'w') {|f| f.write(original_json) }
  end
  
  
  
  get '/jobs' do 
    "there are #{@@jobs.size} jobs queued"
  end
  
  
  get '/check/:md5' do 
    destination_dir = File.join @@public_dir,params[:md5]
    if File.exists?(File.join(destination_dir,'.done'))
      "done"
    else
      "not done"
    end
  end
  
  
  get '/status' do 
    if @@current_job.nil?
      "there is nothing currently running"
    else
      "the current job has completed #{@@completed_steps} out of #{@@current_job.size} packages"
    end
  end
  
  
  post '/build/:project' do 
    original_json = request.body.read
    @@log.debug "got request #{original_json}"
    project = JSON.parse original_json
    md5 = Digest::MD5.hexdigest(project.to_s)
    repo_dir = File.join(@@public_dir,md5)
    destination_dir = File.join @@public_dir,md5
    unless File.exists?(File.join(destination_dir,'.done'))
      puts "calling build_project..."
      @@log.debug "calling build project..."
      begin
        Thread.new {
          work(project,destination_dir,md5,original_json)
        }
      rescue Object => o
        @@log.error "hit error comming back from thread:"
        @@log.error o.inspect
        @@log.error o.backtrace
        Kernel.exit 1
      end
    else
      puts "already built project"
    end
    md5
  end
  
  
  def work(project,destination,md5,original_json)
    begin
      @@log.debug "calling work with #{md5}"
      if @@jobs.include? md5
        STDERR.puts "job has already been queued #{md5}"
        return
      end
      @@jobs << md5
      STDERR.puts "queing job"
      @@mutex.lock
      @@log.debug "aquired mutex lock"
      @@current_job = project
      @@completed_steps = 0
      STDERR.puts "starting job #{md5}"
      build_project project
      deploy_project destination, original_json
      @@jobs.delete md5
      STDERR.puts "done with job #{md5}"
      @@current_job = nil
      @@mutex.unlock
      @@log.debug "released mutex lock"
    rescue Object => o
      @@log.error "hit an error in work unit::"
      @@log.error o.inspect
      @@log.error o.backtrace
      Kernel.exit 1
    end
  end
end
