feature 'プレイヤ編集' do
  given(:user) { create :admin }
  given(:league) { build :league }
  given(:player) { build :player }

  background do
    login user
    create_league(league)
    create_player(player)
    visit players_path
    click_button '編集'

    fill_in 'player[name]', with: 'edit_プレイヤ'
    click_button '更新'
  end

  scenario 'プレイヤを編集する', js: true do
    expect(page).to have_content 'edit_プレイヤ'
  end
end

