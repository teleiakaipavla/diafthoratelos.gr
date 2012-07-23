class AboutWidget < Widget
  field :settings, :type => Hash, :default => {'content' => {}}

  def content
    c = (settings||{})['content'] || {}
    c[I18n.locale.to_s.split("-").first] || c[self.group.language] || self.group.description
  end
end
