class ModelWrapper
  attr_reader :target, :view_context
  alias :orig_respond_to? :respond_to?

  def initialize(target, view_context)
    @target = target
    @view_context = view_context
  end

  # returns the current shapado group the current user is on
  def current_group
    @view_context.current_group
  end

  def respond_to?(method, priv = false)
    self.orig_respond_to?(method, priv) || @target.respond_to?(method, priv)
  end

  def method_missing(name, *args, &block)
    @target.send(name, *args, &block)
  end
end
