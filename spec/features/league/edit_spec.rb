feature 'リーグの編集', state: :league_list do
  background do
    League.create attributes_for :league
    visit leagues_path
    click_button '編集'
    wait_for_action
  end

  feature '更新する', js: true do
    context '名前' do
      background do
        fill_in 'league[name]', with: 'fooリーグ'
        click_button '更新'
        wait_for_action
      end

      scenario '名前の表示が変わる' do
        expect(page).to have_content 'fooリーグ'
      end
    end

    context 'ルール' do
      background do
        fill_in 'rule[change]', with: 10
        fill_in 'rule[take]', with: 100
        fill_in 'rule[try]', with: 1000
        click_button '更新'
        wait_for_action
      end

      scenario 'ルールの表示が変わる' do
        expect(page).to have_content '10-100-1000'
      end
    end
  end
end

