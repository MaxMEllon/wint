feature 'リーグ一覧ページからのアクセス', js: true do
  shared_context 'リーグ一覧画面を表示している', state: :league_request do
    background do
      sign_in (create :admin)
      visit leagues_path
    end
  end

  feature '登録ボタンを押す', state: :league_request do
    background do
      click_button '登録'
      wait_for_action
    end

    scenario '新規登録フォームが表示される' do
      within('div#myModal') do
        expect(page).to have_content 'リーグ作成'
      end
    end
  end
end

