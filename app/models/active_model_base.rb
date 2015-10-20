class ActiveModelBase
  public

  def save
    fail 'Called abstract method'
  end

  def update(_attributes = {})
    fail 'Called abstract method'
  end

  public_class_method

  def self.create(_attributes = {})
    fail 'Called abstract method'
  end

  def self.load(_uniq_elem)
    fail 'Called abstract method'
  end
end

