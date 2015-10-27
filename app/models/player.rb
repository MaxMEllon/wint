# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  league_id  :integer          not null
#  name       :string(255)      not null
#  role       :integer          default(0), not null
#  submit_id  :integer          not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#  data_dir   :string(255)      not null
#

class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  belongs_to :best, class_name: :Submit, foreign_key: :submit_id
  has_many :submits, dependent: :delete_all

  validates :name, presence: true, length: {maximum: 10}

  Scope.active(self)

  ROLE_PARTICIPANT = 0
  ROLE_AUDITOR = 1

  def self.create(attributes)
    league = League.find(attributes[:league_id])
    attributes[:data_dir] = league.source_path + format('/%04d', last_id)
    FileUtils.mkdir(attributes[:data_dir])
    super(attributes)
  end

  def self.last_id
    Player.count == 0 ? 1 : Player.last.id + 1
  end

  def analysis_with_snum
    ["#{self.user.snum}_%03d" % best.number, AnalysisManager.load(best.analysis_file)]
  end

  def auditor?
    self.role == ROLE_AUDITOR
  end

  def self.role_options
    {
      ROLE_PARTICIPANT => '受講者',
      ROLE_AUDITOR => '聴講者'
    }
  end
end

