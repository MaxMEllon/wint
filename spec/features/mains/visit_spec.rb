feature 'マイページへのアクセス' do
  given(:user) { create :admin }
  given(:league) { create :league }
  given(:player) { create(:player, league_id: league.id, user_id: user.id) }

  background do
    login user
    visit main_select_path
    visit main_set_player_path(pid: player.id) # or click_link player.name
  end

  scenario 'マイページに移動する', js: true do
    expect(page).to have_content '戦略提出'
  end

  scenario 'ランキングをクリックすると移動する', js: true do
    visit main_ranking_path
    expect(page).to have_content 'ランキング'
  end
end

