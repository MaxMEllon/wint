feature 'display test of analysis strategy page', state: :analysis_list do
  before(:all) do
    @league = League.create attributes_for :league
    Player.create attributes_for :player
    Submit.create attributes_for :submit
  end

  background do
    visit analysis_strategies_path(lid: @league.id)
  end

  scenario 'file size graph', js: true do
    expect(page).to have_content 'ファイルサイズ'
  end

  scenario 'condition number graph', js: true do
    expect(page).to have_content '制御構文中の条件の数'
  end

  scenario 'method number graph', js: true do
    expect(page).to have_content '関数の定義数'
  end

  scenario 'compression rate graph', js: true do
    expect(page).to have_content '圧縮率'
  end
end

