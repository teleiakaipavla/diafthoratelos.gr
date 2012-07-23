require 'singleton'

class LevelSystem
  include Singleton

  attr_reader :levels

  def initialize
    @levels = []
    (1..200).to_a.map do |e|
      @levels << (@levels.last||0)  + (((e-1)/5)+1)*10
    end
  end

  def level_for(reputation)
    @levels.each_with_index do |rep, index|
      if rep > reputation
        return index+1
      end
    end

    -1
  end

  def limit_for(level)
    @levels[level-1]
  end
end
