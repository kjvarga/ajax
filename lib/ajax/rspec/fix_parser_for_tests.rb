module FixEnv

  # Make sure 'rack.input' has a value in the environment otherwise we
  # get "RuntimeError: Missing rack.input".
  def new(env)
    env['rack.input'] = '' unless env['rack.input']
    super
  end
end
  
Rack::Ajax::Parser.send(:extend, FixEnv)