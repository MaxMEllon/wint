RSpec.describe Rule, type: :model do
  let!(:league) { League.create attributes_for :league }
  let(:rule) { league.rule }
  let(:path) { "#{Rails.root}/tmp/data/001/rule" }

  context '#path' do
    it { expect(rule.path).to eq path }
  end

  context '#change' do
    it { expect(rule.change).to eq 7 }
  end

  context '#take' do
    it { expect(rule.take).to eq 5 }
  end

  context '#try' do
    it { expect(rule.try).to eq 10_000 }
  end

  context '#text' do
    it { expect(rule.text).to eq '07-05-10000' }
  end

  describe 'self.create' do
    context 'path' do
      it { expect(File).to exist rule.path }
    end

    context 'Stock.ini' do
      it { expect(File).to exist path + '/Stock.ini' }
    end

    context 'CardLib.c' do
      it { expect(File).to exist path + '/CardLib.c' }
    end

    context 'Poker.h' do
      it { expect(File).to exist path + '/Poker.h' }
    end

    context 'PokerExec.c' do
      it { expect(File).to exist path + '/PokerExec.c' }
    end

    context 'rule.json' do
      it { expect(File).to exist path + '/rule.json' }
    end
  end
end

