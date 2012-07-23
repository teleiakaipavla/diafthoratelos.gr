class GroupStat
  include Mongoid::Document
  embedded_in :group
  field :pageviews, type: Hash, default: {}

  def viewed!
    key = Time.now.strftime("%Y/%m")
    if self.pageviews[key]
      self.inc(:"pageviews.#{key}", 1)
    else
      self.set(:"pageviews.#{key}", 1)
    end
  end
end
