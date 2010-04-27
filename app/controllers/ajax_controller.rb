class AjaxController < ApplicationController
  after_filter :clear_return_to

  # Don't return to the framework path, return to root
  def clear_return_to
    return unless Ajax.is_enabled?
    if session[:return_to] =~ %r[#{Ajax.framework_path}]
      session[:return_to] = session[:return_to].sub(%r[#{Ajax.framework_path}], '/')
      Rails.logger.info("[ajax] return_to / instead of #{Ajax.framework_path}")
    end
  end

  unloadable # needed when installed as a plugin
end