require 'spec_helper'
require 'fileutils'

# Dummy Rails.root to tmp/
TMP_DIR = Ajax.root + '../../tmp'
Rails = Class.new do
  def self.root
    TMP_DIR
  end
end

def verbose # silence the tasks
  false
end

require 'rake'
load(Ajax.root + 'tasks/ajax_tasks.rake')

context 'task' do
  before :each do
    FileUtils.rm_r(TMP_DIR) if File.exists?(TMP_DIR)
    FileUtils.mkdir(TMP_DIR)
  end

  it "rails root should be tmp/" do
    Rails.root.should == TMP_DIR
  end

  context 'install' do
    it "should install files" do
      Rake::Task['ajax:install'].invoke
      INSTALL_FILES.each do |file|
        file_should_exist(File.join(Rails.root, file))
      end
    end
  end

  context 'update' do
    context 'javascript' do
      it "should update files" do
        Rake::Task['ajax:update:javascript'].invoke
        UPDATE_JAVASCRIPT_FILES.each do |file|
          file_should_exist(File.join(Rails.root, file))
        end
      end
    end
  end
end