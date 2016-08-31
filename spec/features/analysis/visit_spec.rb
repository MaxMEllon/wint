feature '分析ページへのアクセス' do
  given(:user) { create :admin }
  given(:league) { create :league }

  background do
    login user
    create_strategies(league)
  end

  context 'リーグ詳細ページへのリンクを選択した場合' do
    background do
      visit analysis_league_path(lid: league.id)
    end

    scenario 'リーグ詳細ページへ移動する', js: true do
      expect(page).to have_content 'リーグ詳細'
    end
  end

  context '戦略コード分析ページへのリンクを選択した場合' do
    background do
      visit analysis_strategies_path(lid: league.id)
    end

    scenario '戦略コード分析ページへ移動する', js: true do
      expect(page).to have_content '戦略コード分析'
    end
  end

  context 'ランキングページへのリンクを選択した場合' do
    background do
      visit analysis_ranking_path(lid: league.id)
    end

    scenario '管理者用ランキングページへ移動する', js: true do
      expect(page).to have_content '管理者用ランキング'
    end
  end

  context 'プレイヤ詳細ページへのリンクを選択した場合' do
    background do
      player = league.players.first
      visit analysis_player_path(lid: league.id, pid: player.id)
    end

    scenario 'プレイヤ詳細ページへ移動する', js: true do
      expect(page).to have_content 'プレイヤ詳細'
    end
  end

  context '戦略詳細ページを選択した場合' do
    background do
      player = league.players.first
      visit analysis_strategy_path(lid: league.id, pid: player.id, num: player.submits.first.id)
    end

    scenario '各プレイヤの戦略詳細ページへ移動する', js: true do
      expect(page).to have_content '戦略詳細'
    end
  end
end

