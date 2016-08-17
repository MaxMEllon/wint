feature 'ダウンロードリンクへのアクセス' do
  given(:user) { create :admin }
  given(:league) { create :league }

  background do
    login user

    create_strategies(league)
    visit analysis_league_path(lid: league.id)
  end

  context '最良戦略をダウンロードする場合' do
    background do
      click_link '最良戦略 (zip)'
    end

    scenario 'best_strategies.zipがダウンロードされる', js: true do
      expect(page.response_headers['Content-Disposition']).to match 'best_strategies.zip'
    end
  end

  context '全戦略をダウンロードする場合' do
    background do
      click_link '全戦略 (zip)'
    end

    scenario 'all_strategies.zipがダウンロードされる', js: true do
      expect(page.response_headers['Content-Disposition']).to match 'all_strategies.zip'
    end
  end

  context '最良戦略の分析結果をダウンロードする場合' do
    background do
      click_link '最良戦略の分析結果 (csv)'
    end

    scenario 'best_analysis.csvがダウンロードされる', js: true do
      expect(page.response_headers['Content-Disposition']).to match 'best_analysis.csv'
    end
  end

  context '全戦略の分析結果をダウンロードする場合' do
    background do
      click_link '全戦略の分析結果 (csv)'
    end

    scenario 'all_analysis.csvがダウンロードされる', js: true do
      expect(page.response_headers['Content-Disposition']).to match 'all_analysis.csv'
    end
  end
end

