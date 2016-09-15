# == Schema Information
#
# Table name: submits
#
#  id         :integer          not null, primary key
#  player_id  :integer          not null
#  data_dir   :string(255)      default(""), not null
#  comment    :string(255)
#  number     :integer          not null
#  status     :integer          default(0), not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Submit, type: :model do
  let(:league) { create :league_model_test }
  let(:user) { create :student }
  let(:player) { create(:player_model_test, league_id: league.id, user_id: user.id) }
  let(:submit) { create(:submit_model_test, player_id: player.id) }

  it 'idに応じたパスが保存される' do
    expect(submit.data_dir).to eq 'data/test/001/0001/001'
  end

  it 'ディレクトリが生成される' do
    expect(File.exist?(submit.data_dir)).to eq true
  end

  it 'ソースコードが保存される' do
    expect(File.exist?(submit.src_file)).to eq true
  end

  it '実行ファイルが生成される' do
    expect(File.exist?(submit.exec_file)).to eq true
  end
end

