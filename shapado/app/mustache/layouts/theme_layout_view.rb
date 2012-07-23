module Layouts
  class ThemeLayoutView < ThemeViewBase
    def render_layout
      render_buffer current_theme.layout_html.read
    end

    # returns the content that will displayed inside of the layout
    # the content can be the list of question or a question and its answers
    def content
      view_context.content_for(:layout)
    end

    def default_include_stylesheets
      view_context.render 'shared/layout/css'
    end

    def default_include_javascript
      view_context.render 'shared/layout/javascript'
    end

    def default_meta
      view_context.render 'shared/layout/meta'
    end

    def default_analytics
      view_context.render 'shared/analytics'
    end

    def page_title
      view_context.page_title
    end

    def page_class
      view_context.bodys_class(view_context.params).join(" ")
    end

    def default_stylesheets
      view_context.stylesheet_link_tag css_group_path(current_group, params[:test_theme] || current_theme.id, current_theme.version)
    end
  end
end
