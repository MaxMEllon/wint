feature '戦略ファイルの提出' do
  given(:user) { create :admin }
  given(:league) { create :league }
  given(:player) { create(:player, league_id: league.id, user_id: user.id) }

  background do
    login user
    player
    league.update(is_analy: true)
    visit main_select_path
    visit main_set_player_path(pid: player.id) # or click_link player.name
    click_button '戦略提出'

    fill_in 'submit[data_dir]', with: File.read("#{Rails.root}/spec/factories/files/PokerOpe/success.c")
    fill_in 'submit[comment]', with: 'てすと'
    click_button '提出'

    reload_page
    click_link '001'
  end

  scenario '戦略詳細ページに移動する', js: true do
    expect(page).to have_content '戦略詳細'
  end
end

