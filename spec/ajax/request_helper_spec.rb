require 'spec_helper'

include Ajax::Helpers::RequestHelper

describe 'Ajax::Helpers::RequestHelpers' do
  describe 'set_header' do
    before :each do
      @headers = {}
    end

    it "should store headers as JSON" do
      set_header @headers, :tab, '#main .home_tab'
      get_header(@headers, :tab).should == '#main .home_tab'
    end
    
    it "should not fail on bad JSON" do
      @headers['Ajax-Info'] = 'invalid JSON!'
      get_header(@headers, :layout).should be_nil
      
      set_header(@headers, :layout, '')
      get_header(@headers, :layout).should == ''
    end
        
    it "should add headers" do
      set_header @headers, :tab, '#main .home_tab'
      get_header(@headers, :tab).should == '#main .home_tab'
    end
    
    it "should add assets" do
      set_header @headers, :assets, { :key => ['value'] }
      get_header(@headers, :assets).should == { 'key' => ['value'] }
    end
    
    it "should merge hashes" do
      set_header @headers, :assets, { :key1 => 'value1' }
      set_header @headers, :assets, { :key2 => 'value2' }
      get_header(@headers, :assets).should == { 'key1' => 'value1', 'key2' => 'value2' }
    end
    
    it "should concat arrays" do
      set_header @headers, :callbacks, ['one']
      set_header @headers, :callbacks, ['two']
      get_header(@headers, :callbacks).should == ['one', 'two']
    end    

    it "should deep merge" do
      set_header @headers, :assets, { :key => ['value1'] }
      set_header @headers, :assets, { :key => ['value2'] }
      get_header(@headers, :assets).should == { 'key' => ['value1', 'value2'] }
    end    
  end
end