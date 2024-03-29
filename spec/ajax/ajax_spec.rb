require 'spec_helper'

describe Ajax do
  describe "framework path" do
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
    Ajax.root.should == Pathname.new(File.expand_path('../../../', __FILE__))
  end

  it "should tell you the version" do
    Ajax.version.should =~ /\d+\.\d+.\d+/
  end

  it "should have an Application instance" do
    Ajax.app.should be_a(Ajax::Application)
  end

  describe "google crawlable" do
    it "should be off by default" do
      Ajax.crawlable?.should be_false
    end

    it "should be settable" do
      Ajax.crawlable = true
      Ajax.crawlable?.should be_true
      Ajax.crawlable = false
      Ajax.crawlable?.should be_false
    end
  end
end
