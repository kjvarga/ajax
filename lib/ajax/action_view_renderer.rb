ActionView::Renderer.class_eval do
  if !instance_methods.include?('render_with_tracking')
    def render_with_tracking(context, options)
      context.controller.instance_variable_set(:@_rendered_layout, options[:layout])
      render_without_tracking(context, options)
    end
    alias_method_chain :render, :tracking
  end
end
