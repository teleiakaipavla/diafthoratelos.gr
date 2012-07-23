module LayoutHelper
  def tab_entry(element, text, path, options = {}, html_opts = {})
    options[:selected] ||= "selected"
    options[:link_opts] ||= {}

    if request.path == path
      if html_opts[:class]
        html_opts[:class] = "#{html_opts[:class]} #{options[:selected]}"
      else
        html_opts[:class] = options[:selected]
      end
    end

    if element != "a"
      content_tag(element, html_opts) do
        link_to(text, path, options[:link_opts])
      end
    else
      link_to text, path, html_opts.merge(options[:link_opts])
    end
  end

  def pjax_tab_entry(element, text, layout, path, options = {}, html_opts = {})
    link_opts = options[:link_opts] || {}
    if link_opts[:class].nil? || !(link_opts[:class] =~ /pjax/)

      link_opts[:class] = "#{link_opts[:class]} pjax"
    end

    link_opts.merge!(:"data-layout" => layout)
    options[:link_opts] = link_opts

    tab_entry(element, text, path, options, html_opts)
  end

  def pjax_link_to(text, layout, path, options = {})
    klass = "pjax"
    if extra_class = options.delete(:class) || options.delete('class')
      klass << " " << extra_class
    end

    link_to text, path, options.merge(:class => klass, :"data-layout" => layout)
  end

  def render_app_config
    content_tag(:span, "", {:id=>"appconfig",:"data-g"=>current_group.id})
  end

  def questions_link_for(action)
    case action
    when "by_me"
      {"controller" => "questions", "action" => "by_me"}
    when "feed"
      {"controller" => "questions", "action" => "feed"}
    when "preferred"
      {"controller" => "questions", "action" => "preferred"}
    when "expertise"
      {"controller" => "questions", "action" => "expertise"}
    when "contributed"
      {"controller" => "questions", "action" => "contributed"}
    else
      {"controller" => "questions", "action" => "index"}
    end
  end

  def ie_tag(name=:body, attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(name, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(name, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 8]><!-->".html_safe)
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end

  def ie_html(attrs={}, &block)
    ie_tag(:html, attrs, &block)
  end

  def ie_body(attrs={}, &block)
    ie_tag(:body, attrs, &block)
  end

private

  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end
end
