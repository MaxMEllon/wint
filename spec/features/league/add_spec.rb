feature 'リーグの登録', js: true do
  shared_context 'リーグ登録のモーダルを表示している', state: :league_add do
    background do
      sign_in create :admin
      visit leagues_path
      click_button '登録'
      wait_for_action
    end
  end

  feature '作成ボタンを押す' do
    context '何も入力していない場合', state: :league_add do
      background do
        within('div#myModal') do
          click_button '作成'
          wait_for_action
        end
      end

      scenario '失敗する' do
        within('div#myModal') do
          expect(page).to have_content '入力してください'
        end
      end
    end

    context '全て入力している場合', state: :league_add do
      background do
        files_path = "#{Rails.root}/spec/factories/data/001/rule/"
        within('div#myModal') do
          fill_in 'league[name]', with: 'hogeリーグ'
          fill_in 'league[limit_score]', with: '150'
          fill_in 'league[start_at]', with: '2015.09.01 00:00'
          fill_in 'league[end_at]', with: '2015.09.30 00:00'
          attach_file 'file[stock]', files_path + 'Stock.ini'
          attach_file 'file[header]', files_path + 'Poker.h'
          attach_file 'file[exec]', files_path + 'PokerExec.c'
          attach_file 'file[card]', files_path + 'CardLib.c'
          fill_in 'rule[change]', with: 7
          fill_in 'rule[take]', with: 5
          fill_in 'rule[try]', with: 10000
          # FakeFS.activate!
          click_button '作成'
          wait_for_action
          # FakeFS.deactivate!
        end
      end

      scenario 'リーグ一覧に表示が追加される' do
        within('div.leagues.list') do
          expect(page).to have_content 'hogeリーグ'
        end
      end

      scenario 'データが登録されている' do
        league = League.where(name: 'hogeリーグ').first
        expect(league.name).to eq 'hogeリーグ'
      end
    end
  end
end

