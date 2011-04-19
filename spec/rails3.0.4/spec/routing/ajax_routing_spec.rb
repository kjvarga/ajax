require 'spec_helper'

describe AjaxController do
  describe "routing" do
    it "recognizes and generates #framework" do
      { :get => "/ajax/framework" }.should route_to(:controller => "ajax", :action => "framework")
    end
  end
end
