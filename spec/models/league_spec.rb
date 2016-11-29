# == Schema Information
#
# Table name: leagues
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  start_at    :datetime         default(2014-10-24 15:06:30 +0000), not null
#  end_at      :datetime         default(2014-10-24 15:06:30 +0000), not null
#  limit_score :float            default(0.0), not null
#  is_analy    :boolean          default(FALSE), not null
#  data_dir    :string(255)      default(""), not null
#  rule_file   :string(255)      default(""), not null
#  is_active   :boolean          default(TRUE), not null
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe League, type: :model do
  let(:league) { create :league_model_test }

  it 'idに応じたパスが保存される' do
    expect(league.data_dir).to eq 'data/test/001'
  end

  it 'ディレクトリが生成される' do
    expect(File.exist?(league.data_dir)).to eq true
  end

  describe 'League#rank' do
    it '各スコアに対して適切なランクが得られる' do
      rank_list = [nil, 'C', 'X', 'X', 'C', 'X', 'SSSS']
      1.upto(6) do |i|
        sym = ('type' + i.to_s).to_sym
        strategy = create :strategy, sym, submit_id: i
        expect(rank_list[i]).to eq(league.rank(strategy))
      end
    end
  end
end

