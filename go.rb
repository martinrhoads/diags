# this is to try out a sample of what diags may look like to the end user

require File.join(File.dirname(__FILE__),'lib','diags')


git_repo1 = Diags::Node::Git.new('git@github.com:cloudscaling/sheep.git', '878b84b4b404f95f3389d8163114cc497c33ca2e')
git_repo2 = Diags::Node::Git.new('git@github.com:ermal14/diags.git', '117f7e9d5723bb448b50959d1950ea6c632e4a65')

some_dir1 = git_repo1.go
some_dir2 = git_repo2.go
puts "some_dir1 is #{some_dir1}"
puts "some_dir2 is #{some_dir2}"

exit 0

image = Diags::Node::Image.new('precise')


script = <<eos
echo "I am running a script "
eos


custom_image = Diags::Node::CustomImage.new(image,script)

custom_image.build
