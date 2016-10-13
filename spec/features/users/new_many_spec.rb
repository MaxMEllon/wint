feature 'ユーザ一括登録' do
  given(:user) { create :admin }

  background do
    login user
    visit users_path
    click_button '一括登録'
  end

  context '正しく入力された場合' do
    background do
      fill_in 'snum_and_name', with: "s11t111,ほげほげ\ns22t222,ふがふが"
      click_button '作成'
    end

    scenario 'ユーザが作成される', js: true do
      expect(page).to have_content 's11t111'
      expect(page).to have_content 's22t222'
    end
  end

  context '末尾に改行が挿入された場合' do
    background do
      fill_in 'snum_and_name', with: "s11t111,ほげほげ\ns22t222,ふがふが\n"
      click_button '作成'
    end

    scenario 'ユーザが作成される', js: true do
      expect(page).to have_content 's11t111'
      expect(page).to have_content 's22t222'
    end
  end
end

