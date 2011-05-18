require 'spec_helper'
require 'fileutils'

def verbose # silence the tasks
  false
end

require 'rake'
load(Ajax.root + 'tasks/ajax_tasks.rake')

describe 'task' do
  before :all do
    @tmp = Ajax.root + '../../tmp'
    silence_warnings { Rails = stub(:root => @tmp) }
  end

  before :each do
    FileUtils.rm_r(@tmp) if File.exists?(@tmp)
    FileUtils.mkdir(@tmp)
  end

  it "rails root should be tmp/" do
    Rails.root.should == @tmp
  end

  describe 'install' do
    it "should install files" do
      Rake::Task['ajax:install'].invoke
      INSTALL_FILES.each do |file|
        file_should_exist(File.join(Rails.root, file))
      end
    end
  end

  describe 'update' do
    describe 'javascript' do
      it "should update files" do
        Rake::Task['ajax:update:javascript'].invoke
        UPDATE_JAVASCRIPT_FILES.each do |file|
          file_should_exist(File.join(Rails.root, file))
        end
      end
    end
  end
end