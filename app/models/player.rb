class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  has_many :submits, dependent: :delete_all
end

