feature '戦略ファイルの提出' do
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
    click_button '戦略提出'

    attach_file 'submit[data_dir]', "#{Rails.root}/spec/factories/files/PokerOpe.c"
    fill_in 'submit[comment]', with: 'てすと'
    click_button '提出'
  end

  scenario '戦略として登録される', js: true do
    expect(page).to have_content '001'
  end
end

