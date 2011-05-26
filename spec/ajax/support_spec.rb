require "spec_helper"

describe Helpers::OptionHelpers do

  describe_context = self

  it "should make OptionHelpers available everywhere" do
    describe_context.methods.include?('with_option').should be_true
    methods.include?('with_option').should be_true
  end

  it "should set and unset the option" do
    original = Ajax.google_crawlable?
    with_option(:google_crawlable => !original) do
      Ajax.google_crawlable?.should != original
    end
    Ajax.google_crawlable?.should == original
  end
end
