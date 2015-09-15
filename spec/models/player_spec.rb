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

RSpec.describe Player, type: :model do
  describe 'self.create' do
    let(:player) { Player.create attributes_for :player }
    let(:path) { player.league.source_path }

    before do
      League.create attributes_for :league
    end

    context 'data_dir' do
      context '最初の登録の場合' do
        it { expect(player.data_dir).to eq path + '/0001' }
        it { expect(File).to exist player.data_dir }
      end

      context '2番目移行の登録の場合' do
        before { Player.create attributes_for :player }
        it { expect(player.data_dir).to eq path + '/0002' }
      end
    end
  end
end

