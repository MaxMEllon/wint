class User < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_secure_password
end

