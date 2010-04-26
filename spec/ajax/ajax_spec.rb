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
end