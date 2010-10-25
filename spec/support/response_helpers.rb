module ResponseHelpers
  def should_redirect_to(location, code=302)
    should_be_a_valid_response
    response_code.should == code
    response_headers['Location'].should == location
  end
end