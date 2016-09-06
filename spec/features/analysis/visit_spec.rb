feature '分析ページへのアクセス' do
  given(:user) { create :admin }
  given(:league) { create :league_model_test }

  background do
    login user
    create_strategies(league)
  end

  context 'リーグ詳細ページへのリンクを選択した場合' do
    background do
      visit analysis_league_path(lid: league.id)
    end

    scenario 'リーグ詳細ページへ移動する', js: true do
      expect(page).to have_content '日毎の提出数'
      expect(page).to have_content '累計提出数'
    end
  end

  context '戦略コード分析ページへのリンクを選択した場合' do
    background do
      visit analysis_strategies_path(lid: league.id)
    end

    scenario '戦略コード分析ページへ移動する', js: true do
      expect(page).to have_content '最大ABCサイズと得点'
      expect(page).to have_content '学生毎の戦略数'
    end
  end

  context 'プレイヤランキングページへのリンクを選択した場合' do
    background do
      visit analysis_player_ranking_path(lid: league.id)
    end

    scenario 'プレイヤランキングページへ移動する', js: true do
      expect(page).to have_content '最良戦略'
    end
  end

  context '戦略ランキングページへのリンクを選択した場合' do
    background do
      visit analysis_strategy_ranking_path(lid: league.id)
    end

    scenario '戦略ランキングページへ移動する', js: true do
      expect(page).to have_content '戦略名'
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

