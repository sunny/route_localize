# Object that acts like a routeable ActiveRecord model
class Leaf
  def initialize(attributes)
    @attributes = attributes
  end

  def to_param
    @attributes[:id]
  end

  def self.model_name
    self
  end

  def self.singular_route_key
    "leaf"
  end
end
