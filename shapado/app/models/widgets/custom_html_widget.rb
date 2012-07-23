class CustomHtmlWidget < Widget
  field :settings, :type => Hash, :default => {'content' => {}}

  def content
    settings['content'][I18n.locale.to_s.split("-").first] ||
    settings['content'][self.group.language] || ""
  end
end
