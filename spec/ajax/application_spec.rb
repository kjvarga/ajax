require 'spec_helper'

describe Ajax::Application do
  before :each do
    @app = Ajax::Application.new
  end

  describe "rails?" do
    tests = {
      # version => [[arg, should return], ..]
      nil      => [[nil, true], [1, false], [2, false], [3, false]],
      '1.8.10' => [[nil, true], [1, true],  [2, false], [3, false]],
      '2.3.11' => [[nil, true], [1, false], [2, true],  [3, false]],
      '3.0.1'  => [[nil, true], [1, false], [2, false], [3, true]],
      '3.0.11' => [[nil, true], [1, false], [2, false], [3, true]]
    }
    
    tests.each do |version, results|
      it "should identify #{version.inspect} correctly" do
        silence_warnings { Rails = stub(:version => version) }
        results.each do |arg, value|
          @app.rails?(arg).should == value
        end
      end
    end

    it "should match on major version" do
      silence_warnings { Rails = stub(:version => '3.1.0') }
      @app.rails?(:>=, 3).should be_true
      @app.rails?(:<=, 3).should be_true
      @app.rails?(3).should be_true
      @app.rails?(2).should be_false
      @app.rails?(:>=, 2).should be_true
      @app.rails?(:<=, 2).should be_false
    end
    
    it "should match on major.minor version" do
      silence_warnings { Rails = stub(:version => '3.1.0') }
      @app.rails?(:>=, 3.1).should be_true
      @app.rails?(:>=, 3.2).should be_false
      @app.rails?(:<=, 3.1).should be_true
      @app.rails?(:<=, 3.2).should be_true
      @app.rails?(:<=, 3.0).should be_false
      @app.rails?(3.1).should be_true
      @app.rails?(3.0).should be_false
      @app.rails?(3.2).should be_false
    end
  end

  describe "root" do
    it "should be set to the Rails root" do
      silence_warnings { Rails = stub(:root => Ajax.root) }
      Ajax.app.root.should == Rails.root
    end
  end
end
