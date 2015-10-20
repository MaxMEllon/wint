class ActiveModelBase
  public

  def save
    fail 'Called abstract method'
  end

  def update(attributes = {})
    fail 'Called abstract method'
  end

  public_class_method

  def self.create(attributes = {})
    fail 'Called abstract method'
  end

  def self.load(uniq_elem)
    fail 'Called abstract method'
  end
end

