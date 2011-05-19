require "spec_helper"
require 'uri'

include Ajax::RSpec::Helpers

describe "decision tree" do
  describe "snapshot requests", :type => :integration do
    before :all do
      mock_ajax
      create_app
    end

    it "should rewrite to traditional url" do
      call_rack('/?_escaped_fragment_=artists')
      should_rewrite_to('/artists')
    end

    it "the user should be a robot" do
      call_rack('/?_escaped_fragment_=artists')
      should_set_ajax_request_header('robot', true)
    end

    it "should set the snapshot_request header" do
      call_rack('/?_escaped_fragment_=artists')
      should_set_ajax_request_header('snapshot_request', true)
    end

    describe "on excluded paths" do
      before :each do
        @path = '/?_escaped_fragment_=/artists'
        Ajax.exclude_paths('/')
      end

      it "the path should be excluded" do
        Ajax.exclude_path?('/').should be_true
      end

      it "should still rewrite" do
        call_rack(@path)
        should_rewrite_to('/artists')
      end
    end
  end
end
