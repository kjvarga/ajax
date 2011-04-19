class ApplicationController < ActionController::Base
  protect_from_forgery
  ajax_layout 'test'

  def index
    ajax_header :callbacks, 'alert("booya");'
    #redirect_to '/test'
    render
  end

  def test
    render :text => 'In text'
  end
end
