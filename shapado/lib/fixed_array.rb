class FixedArray < Array
  def initialize(max_size = 10)
    @max_size = max_size
  end

  def add(element)
    self.push(element)
    if size > @max_size
      self.shift
    end
    self
  end
end
