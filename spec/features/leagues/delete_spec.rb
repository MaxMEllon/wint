feature 'リーグ削除' do
  given(:user) { create :admin }
  given(:league) { build :league }

  background do
    login user
    create_league(league)
    visit leagues_path
  end

  context 'リーグが有効な場合', js: true do
    background do
      click_button '無効化'
    end

    scenario 'リーグを削除できる' do
      expect(page).to have_button '有効化'
    end
  end

  context 'リーグが無効な場合', js: true do
    background do
      League.first.update(is_active: false)
      reload_page
      click_button '有効化'
    end

    scenario 'リーグを有効化できる' do
      expect(page).to have_button '無効化'
    end
  end
end

