module Helpers
  module FileHelpers
    def files_should_be_identical(first, second)
      identical_files?(first, second).should be(true)
    end

    def files_should_not_be_identical(first, second)
      identical_files?(first, second).should be(false)
    end

    def file_should_exist(file)
      File.exists?(file).should be(true)
    end

    def file_should_not_exist(file)
      File.exists?(file).should be(false)
    end

    def identical_files?(first, second)
      open(second, 'r').read.should == open(first, 'r').read
    end
  end

  module ResponseHelpers
    def should_redirect_to(location, code=302)
      should_be_a_valid_response
      response_code.should == code
      response_headers['Location'].should == location
    end
  end

  module OptionHelpers
    # Sets the options on Ajax, yields to the block and then restores the original
    # options after the block completes.
    def with_options(opts, &block)
      original = opts.collect { |option, value| Ajax.send("#{option}?") }
      yield
      opts.keys.zip(original).each { |option, value| Ajax.send("#{option}=", value) }
    end
  end

  def self.included(receiver)
    receiver.send(:include, FileHelpers)
    receiver.send(:include, ResponseHelpers)
    receiver.send(:include, OptionHelpers)
  end
end
