feature 'display test of analysis player page', state: :analysis_list do
  background do
    league = League.create attributes_for :league
    player = Player.create attributes_for :player
    Submit.create attributes_for :submit
    visit analysis_player_path(lid: league.id, pid: player.id)
  end

  scenario 'score graph', js: true do
    expect(page).to have_content '得点の推移'
  end
end

