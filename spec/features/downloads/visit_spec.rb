feature 'ダウンロードリンクへのアクセス' do
  given(:user) { create :admin }
  given(:league) { create :league }
  given(:player) { create(:player, league_id: league.id, user_id: user.id) }

  background do
    login user
    player

    visit main_select_path
    visit main_set_player_path(pid: player.id) # or click_link player.name
    click_button '戦略提出'

    fill_in 'submit[data_dir]', with: File.read("#{Rails.root}/spec/factories/files/PokerOpe/success.c")
    fill_in 'submit[comment]', with: 'てすと'
    click_button '提出'

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

