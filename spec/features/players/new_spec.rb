feature 'プレイヤ登録' do
  given(:user) { create :admin }
  given(:league) { create :league_model_test }

  background do
    login user
    league

    visit players_path
    click_button 'ユーザ選択画面へ'

    select league.name, from: 'league_id'
    check 'user_id[1]'
    click_button 'プレイヤ登録画面へ'

    # fill_in 'player[1][name]', with: 's00t000_player'
    click_button 'プレイヤ一括登録'
  end

  scenario 'プレイヤを作成する', js: true do
    expect(page).to have_content user.name
  end
end

