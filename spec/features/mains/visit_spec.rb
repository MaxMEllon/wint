feature 'マイページへのアクセス' do
  given(:user) { create :admin }
  given(:league) { build :league }
  given(:player) { build :player }

  background do
    login user
    create_league(league)
    allow_any_instance_of(League).to receive(:open?).and_return(true)
    create_player(player)
    visit main_select_path
    visit main_set_player_path(pid: 1) # or click_link player.name
  end

  scenario 'マイページに移動する', js: true do
    expect(page).to have_content '戦略提出'
  end

  scenario 'ランキングをクリックすると移動する', js: true do
    visit main_ranking_path
    expect(page).to have_content 'ランキング'
  end
end

