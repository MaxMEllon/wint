feature 'download test of analysis league page', state: :analysis_list do
  background do
    league = League.create attributes_for :league
    create :student
    Player.create attributes_for :player
    Submit.create attributes_for :submit
    visit analysis_league_path(lid: league.id)
  end

  context 'when download link of best strategies clicked' do
    background do
      click_link '最良戦略 (zip)'
      wait_for_action
    end

    scenario 'get best strategies zip file' do
      expect(
        page.response_headers['Content-Disposition']
      ).to match 'best_strategies.zip'
    end
  end

  context 'when download link of all strategies clicked' do
    background do
      click_link '全戦略 (zip)'
      wait_for_action
    end

    scenario 'get all strategies zip file' do
      expect(
        page.response_headers['Content-Disposition']
      ).to match 'all_strategies.zip'
    end
  end

  context 'when download link of best analysis clicked' do
    background do
      click_link '最良戦略の分析結果 (csv)'
      wait_for_action
    end

    scenario 'get best analysis zip file' do
      expect(
        page.response_headers['Content-Disposition']
      ).to match 'best_analysis.csv'
    end
  end

  context 'when download link of all analysis clicked' do
    background do
      click_link '全戦略の分析結果 (csv)'
      wait_for_action
    end

    scenario 'get all analysis zip file' do
      expect(
        page.response_headers['Content-Disposition']
      ).to match 'all_analysis.csv'
    end
  end
end

