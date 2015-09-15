shared_context 'マイページを表示している', state: :main_mypage do
  given(:player) { Player.create attributes_for :player }

  background do
    sign_in create :student
    League.create attributes_for :league
    allow_any_instance_of(League).to receive(:open?).and_return(true)
    visit main_set_player_path(pid: player.id)
  end
end

