require "spec_helper"

describe Helpers::OptionHelpers do

  describe_context = self

  it "should be available everywhere" do
    describe_context.methods.include?('with_option').should be_true
    methods.include?('with_option').should be_true
  end

  describe "set_option" do
    it "should set the option and return the original" do
      original = Ajax.google_crawlable?
      set_option(:google_crawlable => !original).should == [original]
      Ajax.google_crawlable?.should_not == original
    end
  end

  describe "with_option" do
    it "should set and unset the option" do
      original = Ajax.google_crawlable?
      with_option(:google_crawlable => !original) do
        Ajax.google_crawlable?.should_not == original
      end
      Ajax.google_crawlable?.should == original
    end
  end

  describe "with_each_option" do
    it "should set each option in turn" do
      original = Ajax.google_crawlable?
      with_each_option({:google_crawlable => [false, true]}, [false, true]) do |value|
        Ajax.google_crawlable?.should == value
      end
      Ajax.google_crawlable?.should == original
    end
  end
end
