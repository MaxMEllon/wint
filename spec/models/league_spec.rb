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
    let(:path) { "#{Rails.root}/tmp/data" }

    before(:all) do
      @league = League.create attributes_for :league
    end

    context 'data_dir' do
      context '最初の登録の場合' do
        it { expect(@league.data_dir).to eq path + '/001' }
        it { expect(File).to exist @league.data_dir }
      end

      context '2番目移行の登録の場合' do
        subject { League.create(attributes_for :league).data_dir }
        it { is_expected.to eq path + '/002' }
      end
    end

    context 'rule_path' do
      it { expect(@league.rule_path).to eq path + '/001/rule' }
      it { expect(File).to exist @league.rule_path }
    end

    context 'source_path' do
      it { expect(@league.source_path).to eq path + '/001/source' }
      it { expect(File).to exist @league.source_path }
    end
  end
end

