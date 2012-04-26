# this is to try out a sample of what diags may look like to the end user

require File.join(File.dirname(__FILE__),'lib','diags')


git_repo = Diags::Node::Repo.new('http://some.git.repo', "123456")
image = Diags::Node::Image.new('precise')


script = <<eos
echo "I am running a script "
eos


custom_image = Diags::Node::CustomImage.new(image,script)

