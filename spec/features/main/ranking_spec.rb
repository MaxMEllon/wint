feature 'Access check to ranking page', state: :main_mypage do
  context 'when ranking page link clicked' do
    background do
      click_link 'ランキング'
    end

    scenario 'move to ranking page' do
      expect(page).to have_content '全体ランキング'
    end
  end
end

