require 'spec_helper'
require 'ajax/rspec/helpers'

include Ajax::RSpec::Helpers

describe AjaxController do
  before :all do
    integrate_ajax
    mock_ajax
  end

  it "should render the framework" do
    get :framework
    response.status.to_s.should =~ /200/
  end

  after :all do
    disable_ajax
    unmock_ajax
  end
end
