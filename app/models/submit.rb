class Submit < ActiveRecord::Base
  belongs_to :player
  belongs_to :strategy
end

