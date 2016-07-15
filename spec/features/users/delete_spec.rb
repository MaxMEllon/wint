feature 'ユーザ削除' do
  given(:user) { create :admin }

  background do
    login user
    visit users_path
  end

  context 'ユーザが有効な場合', js: true do
    background do
      click_button '無効化'
    end

    scenario 'ユーザを削除できる' do
      expect(page).to have_button '有効化'
    end
  end

  context 'ユーザが無効な場合', js: true do
    background do
      user.update(is_active: false)
      reload_page
      click_button '有効化'
    end

    scenario 'ユーザを有効化できる' do
      expect(page).to have_button '無効化'
    end
  end
end

