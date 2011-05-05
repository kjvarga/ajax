require "spec_helper"
require 'ajax/action_controller'

describe Ajax::ActionController do
  before :each do
    Ajax::ActionController.stubs(:included) # disable the method body
    @controller = Class.new do
      include Ajax::ActionController
    end.new
    @request = mock('request')
    @request.stubs(:user_agent).returns('')
    @controller.stubs(:request).returns(@request)
  end

  describe "with nil referer" do
    before :each do
      @headers = {
        'Referer' => nil,
        'Ajax-Info' => { 'referer' => nil }
      }
      @request.stubs(:headers).returns(@headers)
    end

    it "the mock should have nil referers" do
      @request.headers['Ajax-Info']['referer'].should be_nil
      @request.headers['Referer'].should be_nil
    end

    it "should not fail" do
      lambda { @controller.send(:_ajax_redirect, nil, 302) }.should_not raise_error(NoMethodError)
    end
  end

  describe "with nil Ajax-Info referer" do
    before :each do
      @referer = 'https://stage.kazaa.com'
      @headers = {
        'Referer' => @referer,
        'Ajax-Info' => { 'referer' => nil }
      }
      @request.stubs(:headers).returns(@headers)
    end

    it "the mock should have a nil Ajax-Info referer" do
      @request.headers['Referer'].should == @referer
      @request.headers['Ajax-Info']['referer'].should be_nil
    end

    it "should not fail" do
      lambda { @controller.send(:_ajax_redirect, @referer, 302) }.should_not raise_error(NoMethodError)
    end
  end
end
