require "spec_helper"

describe Ajax::RSpec::OptionHelpers do

  describe_context = self

  it "should be available everywhere" do
    describe_context.methods.include?('with_option').should be_true
    methods.include?('with_option').should be_true
  end

  describe "set_option" do
    it "should set the option and return the original" do
      original = Ajax.crawlable?
      set_option(:crawlable => !original).should == [original]
      Ajax.crawlable?.should_not == original
    end
  end

  describe "with_option" do
    it "should set and unset the option" do
      original = Ajax.crawlable?
      with_option(:crawlable => !original) do
        Ajax.crawlable?.should_not == original
      end
      Ajax.crawlable?.should == original
    end
  end

  describe "with_each_option" do
    it "should set each option in turn" do
      original = Ajax.crawlable?
      with_each_option({:crawlable => [false, true]}, [false, true]) do |value|
        Ajax.crawlable?.should == value
      end
      Ajax.crawlable?.should == original
    end
  end
end
