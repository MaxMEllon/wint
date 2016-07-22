feature 'プレイヤ編集' do
  given(:user) { create :admin }
  given(:league) { create :league }
  given(:player) { create(:player, league_id: league.id, user_id: user.id) }

  background do
    login user
    player
    visit players_path
    click_button '編集'

    fill_in 'player[name]', with: 'edit_プレイヤ'
    click_button '更新'
  end

  scenario 'プレイヤを編集する', js: true do
    expect(page).to have_content 'edit_プレイヤ'
  end
end

