class User < ActiveRecord::Base
  has_many :players, dependent: :destroy
  has_secure_password

  CATEGORY_STUDENT = 0
  CATEGORY_TA = 1
  CATEGORY_TEACHER = 2
  CATEGORY_GUEST = 3

  DEPART_RISE_ENIE = 0
  DEPART_OTHER = 1

  def self.category_options
    {
      CATEGORY_STUDENT => '学生',
      CATEGORY_TA      => '補助者',
      CATEGORY_TEACHER => '教授者',
      CATEGORY_GUEST   => '学外者'
    }
  end

  def self.depart_options
    {
      DEPART_RISE_ENIE => '信頼・電子情報',
      DEPART_OTHER     => 'その他'
    }
  end
end

