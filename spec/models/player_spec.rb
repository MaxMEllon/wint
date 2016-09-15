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

require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:league) { create :league_model_test }
  let(:user) { create :student }
  let(:player) { create(:player_model_test, league_id: league.id, user_id: user.id) }

  it 'idに応じたパスが保存される' do
    expect(player.data_dir).to eq 'data/test/001/0001'
  end

  it 'ディレクトリが生成される' do
    expect(File.exist?(player.data_dir)).to eq true
  end
end

