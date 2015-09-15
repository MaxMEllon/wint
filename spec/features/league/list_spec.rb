feature 'リーグ一覧ページからのアクセス', state: :league_list do
  feature '登録ボタンを押す', js: true do
    background do
      click_button '登録'
      wait_for_action
    end

    scenario '新規登録フォームが表示される' do
      expect(page).to have_content 'リーグ作成'
    end
  end
end

