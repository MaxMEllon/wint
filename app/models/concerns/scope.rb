module Scope
  def active(base)
    base.class_eval do
      scope :active, -> { where(is_active: true) }
    end
  end

  module_function :active
end

