# Track rendering of layouts for Rails >= 3.1.  This is called each time something
# is rendered.  The main layout is rendered first.
ActionView::Renderer.class_eval do
  if !instance_methods.include?('render_with_tracking')
    def render_with_tracking(context, options)
      if options[:layout] && !context.controller.instance_variable_get(:@_rendered_layout)
        context.controller.instance_variable_set(:@_rendered_layout, options[:layout])
      end
      render_without_tracking(context, options)
    end
    alias_method_chain :render, :tracking
  end
end
