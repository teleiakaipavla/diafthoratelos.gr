class SuggestionsWidget < Widget
  before_save :limit_to_int
  field :settings, :type => Hash, :default => { :limit => 5 }

  protected
end
