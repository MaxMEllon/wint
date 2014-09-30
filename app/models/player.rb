class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  belongs_to :best, class_name: :Submit, foreign_key: :submit_id
  has_many :submits, dependent: :delete_all
  has_many :strategies, through: :submits

  ROLE_PARTICIPANT = 0
  ROLE_AUDIENCE = 1

  def self.role_options
    {
      ROLE_PARTICIPANT => '受講者',
      ROLE_AUDIENCE => '聴講者'
    }
  end

  def mkdir
    (self.league.data_dir + "/source/%04d" % self.id).tap do |path|
      Dir::mkdir(path)
    end
  end
end

