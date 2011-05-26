require "spec_helper"

describe Helpers::OptionHelpers do
  it "should set and unset the option" do
    original = Ajax.google_crawlable?
    with_options(:google_crawlable => !original) do
      Ajax.google_crawlable?.should != original
    end
    Ajax.google_crawlable?.should == original
  end
end
