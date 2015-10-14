feature 'display test of analysis league page', state: :analysis_list do
  background do
    league = League.create attributes_for :league
    visit analysis_league_path(lid: league.id)
  end

  scenario 'submission number graph per day', js: true do
    expect(page).to have_content '日毎の提出数'
  end

  scenario 'submission number graph', js: true do
    expect(page).to have_content '累計提出数'
  end
end

