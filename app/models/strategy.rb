class Strategy < ActiveRecord::Base
  has_one :submit

  # override
  def create
  end
end

