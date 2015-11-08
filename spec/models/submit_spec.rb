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

RSpec.describe Submit, type: :model do
  describe 'self.create' do
    let(:path) { "#{Rails.root}/tmp/data/001/source/0001" }

    before(:all) do
      League.create attributes_for :league
      Player.create attributes_for :player
      @submit = Submit.create attributes_for :submit
    end

    context 'data_dir' do
      context 'when the first create' do
        it { expect(@submit.data_dir).to eq path + '/001' }
        it { expect(File).to exist @submit.data_dir }
      end

      context 'when the second create' do
        subject { Submit.create(attributes_for :submit).data_dir }
        it { is_expected.to eq path + '/002' }
      end
    end

    context 'src_file' do
      it { expect(@submit.src_file).to eq path + '/001/PokerOpe.c' }
      it { expect(File).to exist @submit.src_file }
    end

    context 'exec_file' do
      it { expect(@submit.exec_file).to eq path + '/001/PokerOpe' }
      it { expect(File).to exist @submit.exec_file }
    end
  end
end

