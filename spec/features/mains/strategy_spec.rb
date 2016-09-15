feature '戦略詳細の閲覧' do
  given(:user) { create :admin }
  given(:league) { create(:league, is_analy: true) }

  background do
    login user

    player = create(:player1, league_id: league.id, user_id: user.id)
    submit = create(:submit, player_id: player.id)
    create(:strategy, :type1, submit_id: submit.id)

    Dir.mkdir("#{Rails.root}/data/test")
    `cp -r #{Rails.root}/spec/factories/files/001 #{league.data_dir}`

    visit main_select_path
    visit main_set_player_path(pid: player.id) # or click_link player.name

    click_link '001'
  end

  scenario '戦略詳細ページに移動する', js: true do
    expect(page).to have_content '戦略詳細'
  end
end

