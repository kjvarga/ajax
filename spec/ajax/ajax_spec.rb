require 'spec_helper'

context Ajax do
  context "framework path" do
    it "should be /ajax/framework by default" do
      Ajax.framework_path.should_not be_nil
      Ajax.framework_path.should == '/ajax/framework'
    end

    it "should be able to be changed" do
      Ajax.framework_path = '/my/path'
      Ajax.framework_path.should == '/my/path'
    end
  end

  it "should have a root method" do
    Ajax.root.should == File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  end
  
  it "should tell you the version" do
    Ajax.version.should =~ /\d+\.\d+.\d+/
  end  
end