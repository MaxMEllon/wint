class League < ActiveRecord::Base
  has_many :players, dependent: :destroy

  validates_presence_of :name, :start_at, :end_at, :limit_score

  def set_src
  end

  def set_rule
  end
end

