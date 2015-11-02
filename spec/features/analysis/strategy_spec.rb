feature 'display test of analysis strategy page', state: :analysis_list do
  before(:all) do
    @league = League.create attributes_for :league
    @player = Player.create attributes_for :player
    @submit = Submit.create attributes_for :submit
  end

  background do
    visit analysis_strategy_path(lid: @league.id, pid: @player.id, num: @submit.number)
  end

  scenario 'file size graph', js: true do
    expect(page).to have_content 'ファイルサイズと得点'
  end

  scenario 'condition number graph', js: true do
    expect(page).to have_content '制御構文中の条件の数と得点'
  end

  scenario 'method number graph', js: true do
    expect(page).to have_content '関数の定義数と得点'
  end

  scenario 'compression rate graph', js: true do
    expect(page).to have_content '圧縮率と得点'
  end

  scenario 'standard degree graph', js: true do
    expect(page).to have_content '偏差度'
  end
end

