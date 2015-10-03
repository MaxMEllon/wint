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

  context 'リーグが登録済みの場合' do
    background do
      League.create attributes_for :league
      visit leagues_path
    end

    feature '編集ボタンを押す', js: true do
      background do
        click_button '編集'
        wait_for_action
      end

      scenario '編集フォームが表示される' do
        expect(page).to have_content 'リーグ編集'
      end
    end

    feature '非公開中ボタンを押す', js: true do
      background do
        click_button '非公開中'
        wait_for_action
      end

      scenario '表示が公開中に変わる' do
        expect(page).to have_content '公開中'
      end
    end

    feature '無効化ボタンを押す', js: true do
      background do
        click_button '無効化'
        wait_for_action
      end

      scenario '表示が有効化に変わる' do
        expect(page).to have_content '有効化'
      end
    end
  end
end

