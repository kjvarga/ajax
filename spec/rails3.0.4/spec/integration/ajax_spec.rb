require 'spec_helper'
require 'uri'
require 'ajax/rspec'

include Ajax::RSpec::Helpers

# Test the Rack::Ajax handling of urls according to our block from
# <tt>config/initializers/ajax.rb</tt>
#
# Test Rack middleware using integration tests because the Spec controller tests
# do not invoke Rack.
describe 'Rack::Ajax' do
  before :each do
    mock_ajax      # Force a return from Rack::Ajax
  end

  after :all do
    unmock_ajax
  end

  describe "XMLHttpRequest" do
    describe "hashed url" do
      it "should rewrite GET request" do
        xhr(:get, '/?query1#/Beyonce?query2')
        should_rewrite_to('/Beyonce?query2')
      end

      it "should not modify POST" do
        xhr(:post, '/#/user_session/new?param1=1&param2=2')
        should_not_modify_request
      end
    end

    describe "traditional url" do
      it "should not be modified" do
        xhr(:get, '/Beyonce')
        should_not_modify_request
      end

      it "should not be modified" do
        xhr(:post, '/user_session/new?param1=1&param2=2')
        should_not_modify_request
      end
    end
  end

  describe "request for root url" do
    it "should not be modified" do
      get('/')
      should_not_modify_request
    end

    it "should not be modified" do
      get('/?query_string')
      should_not_modify_request
    end

    it "should be rewritten if it is hashed" do
      get('/?query1#/Beyonce?query2')
      should_rewrite_to('/Beyonce?query2')
    end
  end

  describe "robot" do
    it "should not modify request for root" do
      get('/', nil, 'HTTP_USER_AGENT' => "Googlebot")
      should_not_modify_request
    end

    it "should not modify traditional requests" do
      get('/Beyonce', nil, 'HTTP_USER_AGENT' => "Googlebot")
      should_not_modify_request
    end

    describe "request hashed" do
      describe "non-root url" do
        it "should not modify the request" do
          get('/Akon/?query1#/Beyonce?query2', nil, 'HTTP_USER_AGENT' => "Googlebot")
          should_not_modify_request
        end
      end

      describe "root url" do
        it "should rewrite to traditional url" do
          get('/#/Beyonce?query2', nil, 'HTTP_USER_AGENT' => "Googlebot")
          should_rewrite_to('/Beyonce?query2')
        end
      end
    end
  end

  describe "regular user" do
    it "should not modify request for root" do
      get('/')
      should_not_modify_request
    end

    it "should ignore query string on root url" do
      get('/?query1#/Beyonce?query2')
      should_rewrite_to('/Beyonce?query2')
    end

    describe "request hashed" do
      describe "non-root url" do
        it "should redirect to hashed part at root" do
          get('/Akon/?query1#/Beyonce?query2')
          should_redirect_to('/#/Beyonce?query2')
        end
      end

      describe "root url" do
        it "should rewrite to traditional url" do
          get('/#/Beyonce?query2')
          should_rewrite_to('/Beyonce?query2')
        end
      end
    end

    describe "request traditional url" do
      it "should not be modified" do
        get('/')
        should_not_modify_request
      end
      it "should not be modified" do
        get('/?query_string')
        should_not_modify_request
      end

      it "should redirect GET request" do
        get('/Beyonce')
        should_redirect_to('/#/Beyonce')
      end

      it "should not modify non-GET request" do
        %w[post put delete].each do |method|
          send(method, '/')
          should_not_modify_request
        end
      end
    end
  end
end
