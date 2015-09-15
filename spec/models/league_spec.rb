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

    context 'data_dir' do
      context '最初の登録の場合' do
        it { expect(league.data_dir).to eq path + '/001' }
      end
      context '2番目移行の登録の場合' do
        before { League.create attributes_for :league }
        it { expect(league.data_dir).to eq path + '/002' }
      end
    end

    context 'rule_path' do
      it { expect(league.rule_path).to eq path + '/001/rule' }
      it { expect(File).to exist league.rule_path }
      it '解凍されたファイルが存在すること' do
        expect(`ls #{league.rule_path} | wc -w`.to_i > 0).to be true
      end
    end

    context 'source_path' do
      it { expect(league.source_path).to eq path + '/001/source' }
      it { expect(File).to exist league.source_path }
    end

    context 'compile_command' do
      it { expect(league.compile_command).to be_truthy }
    end

    context 'exec_command' do
      it { expect(league.exec_command).to be_truthy }
    end
  end

end

