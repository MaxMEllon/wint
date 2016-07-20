module ActionHelper
  def create_league(league)
    visit leagues_path
    click_button '登録'

    fill_in 'league[name]', with: league.name
    fill_in 'league[limit_score]', with: league.limit_score
    fill_in 'league[start_at]', with: league.start_at
    fill_in 'league[end_at]', with: league.end_at

    fill_in 'rule[change]', with: 7
    fill_in 'rule[take]', with: 5
    fill_in 'rule[try]', with: 10_000

    click_button '作成'
  end

  def create_player(_player)
    visit players_path
    click_button 'ユーザ選択画面へ'

    select league.name, from: 'league_id'
    check 'user_id[1]'
    click_button 'プレイヤ登録画面へ'

    # fill_in 'player[1][name]', with: player.name
    click_button 'プレイヤ一括登録'
  end

  def create_submit
    visit main_select_path
    visit main_set_player_path(pid: 1) # or click_link player.name
    click_button '戦略提出'

    attach_file 'submit[data_dir]', "#{Rails.root}/spec/factories/files/PokerOpe.c"
    fill_in 'submit[comment]', with: 'てすと'
    click_button '提出'
  end

  def reload_page
    visit current_path
  end
end

