# == Schema Information
#
# Table name: strategies
#
#  id         :integer          not null, primary key
#  submit_id  :integer          not null
#  score      :float            default(0.0), not null
#  number     :integer          not null
#  analy_file :string(255)      default(""), not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Strategy, type: :model do
  let(:league) { create :league_model_test }
  let(:user) { create :student }
  let(:player) { create(:player_model_test, league_id: league.id, user_id: user.id) }
  let(:submit) { create(:submit_model_test, player_id: player.id) }
  let(:strategy) { submit.strategy }

  it '分析用のディレクトリが生成される' do
    expect(File.exist?(submit.analysis_path)).to eq true
  end

  it 'adlint分析用のファイルが生成される' do
    path = submit.analysis_path + '/adlint'
    expect(File.exist?(path)).to eq true
    expect(File.exist?(path + '/adlint.c')).to eq true
    expect(File.exist?(path + '/output/adlint.c.met.csv')).to eq true
    expect(File.exist?(path + '/output/adlint.c.msg.csv')).to eq true
  end

  it 'code分析用のファイルが生成される' do
    path = submit.analysis_path + '/code'
    expect(File.exist?(path)).to eq true
    expect(File.exist?(path + '/comcut.c')).to eq true
  end

  it 'log分析用のファイルが生成される' do
    path = submit.analysis_path + '/log'
    expect(File.exist?(path)).to eq true
    expect(File.exist?(path + '/Game.log')).to eq true
  end

  it 'result分析用のファイルが生成される' do
    path = submit.analysis_path + '/result'
    expect(File.exist?(path)).to eq true
    expect(File.exist?(path + '/Result.txt')).to eq true
  end
end

