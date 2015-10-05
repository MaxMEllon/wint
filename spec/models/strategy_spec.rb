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

RSpec.describe Strategy, type: :model do
  describe 'self.create' do
    let(:strategy) { Strategy.find(1) }
    let(:path) { "#{Rails.root}/tmp/data/001/source/0001/001/analy/" }

    before do
      League.create attributes_for :league
      Player.create attributes_for :player
      Submit.create attributes_for :submit
    end

    context 'analy_file' do
      it { expect(strategy.analy_file).to eq path + 'analy.json' }
      it { expect(File).to exist strategy.analy_file }
    end

    context 'code analysis' do
      it { expect(File).to exist path + 'code/cflow.dat' }
      it { expect(File).to exist path + 'code/comcut.c' }
      it { expect(File).to exist path + 'code/comcut.gz' }
      it { expect(File).to exist path + 'code/func_ref.csv' }
    end

    context 'log analysis' do
      it { expect(File).to exist path + 'log/Game.log' }
    end

    context 'result analysis' do
      it { expect(File).to exist path + 'result/Result.txt' }
    end
  end
end

