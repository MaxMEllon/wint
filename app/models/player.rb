class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  has_many :submits, dependent: :delete_all

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

