feature '分析ページへのアクセス' do
  given(:user) { create :admin }
  given(:league) { build :league }
  given(:player) { build :player }

  background do
    login user
    create_league(league)
    allow_any_instance_of(League).to receive(:open?).and_return(true)
    create_player(player)
    create_submit
  end

  context 'リーグ詳細ページへのリンクを選択した場合' do
    background do
      visit analysis_league_path(lid: 1)
    end

    scenario 'リーグ詳細ページへ移動する', js: true do
      expect(page).to have_content 'リーグ詳細'
    end
  end

  context '戦略コード分析ページへのリンクを選択した場合' do
    background do
      visit analysis_strategies_path(lid: 1)
    end

    scenario '戦略コード分析ページへ移動する', js: true do
      expect(page).to have_content '戦略コード分析'
    end
  end

  context 'ランキングページへのリンクを選択した場合' do
    background do
      visit analysis_ranking_path(lid: 1)
    end

    scenario '管理者用ランキングページへ移動する', js: true do
      expect(page).to have_content '管理者用ランキング'
    end
  end

  context '戦略詳細ページを選択した場合' do
    background do
      visit analysis_strategy_path(lid: 1, pid: 1, num: 1)
    end

    scenario '各プレイヤの戦略詳細ページへ移動する', js: true do
      expect(page).to have_content '戦略詳細'
    end
  end
end

