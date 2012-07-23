class CollectionWrapper < Enumerator
  attr_reader :target, :wrapper_klass, :view_context

  def initialize(target, wrapper_klass, view_context)
    @target = target
    @view_context = view_context
    @wrapper_klass = wrapper_klass
  end

  def map(&block)
    @target.map do |doc|
      c = @wrapper_klass.new(doc, view_context)

      block.call(c)
    end
  end
end
