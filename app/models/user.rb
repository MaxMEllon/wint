# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  snum            :string(255)      not null
#  name            :string(255)      not null
#  depart          :integer          default(0), not null
#  entrance        :integer          default(2012), not null
#  category        :integer          default(0), not null
#  is_active       :boolean          default(TRUE), not null
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  CATEGORY_STUDENT = 0
  CATEGORY_TA = 1
  CATEGORY_TEACHER = 2
  CATEGORY_GUEST = 3

  DEPART_RISE_ENIE = 0
  DEPART_OTHER = 1

  ENTRANCE_START = 2000

  has_many :players, dependent: :destroy
  has_many :leagues, through: :players

  Scope.active(self)

  has_secure_password

  validates_presence_of :snum, :name
  validates_inclusion_of :category, in: [CATEGORY_STUDENT, CATEGORY_TA, CATEGORY_TEACHER, CATEGORY_GUEST]
  validates_inclusion_of :depart, in: [DEPART_RISE_ENIE, DEPART_OTHER]

  def admin?
    self.category == CATEGORY_TEACHER
  end

  def teacher_side?
    self.admin? || self.category == CATEGORY_TA
  end

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

