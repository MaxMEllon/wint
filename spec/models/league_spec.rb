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

RSpec.describe League, type: :model do
  describe 'self.create' do
    let(:league) { League.create attributes_for :league }
    let(:path) { "#{Rails.root}/tmp/data" }

    context '最初の登録の場合' do
      context 'data_dir' do
        it { expect(league.data_dir).to eq path + '/001' }
      end

      context 'rule_path' do
        it { expect(league.rule_path).to eq path + '/001/rule' }
      end

      context 'source_path' do
        it { expect(league.source_path).to eq path + '/001/source' }
      end

      context 'exist rule_path' do
        it { expect(File.exist?(league.rule_path)).to be true }
      end

      context 'exist source_path' do
        it { expect(File.exist?(league.source_path)).to be true }
      end
    end

    context '2番目移行の登録の場合' do
      before { League.create attributes_for :league }
      context 'data_dir' do
        it { expect(league.data_dir).to eq path + '/002' }
      end
    end
  end
end

