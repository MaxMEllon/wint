class User < ActiveRecord::Base
  has_many :players, dependent: :destroy

  has_secure_password

  validates_presence_of :snum, :name

  CATEGORY_STUDENT = 0
  CATEGORY_TA = 1
  CATEGORY_TEACHER = 2
  CATEGORY_GUEST = 3

  DEPART_RISE_ENIE = 0
  DEPART_OTHER = 1

  ENTRANCE_START = 2000

  def self.select_format
    self.all.map {|u| [u.name, u.id]}
  end

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

  def self.entrance_options
    [0] + (ENTRANCE_START..Time.new.year).to_a
  end
end

