RSpec.describe LeaguesController, type: :feature do
  feature 'リーグ一覧ページへのアクセス' do
    background do
      sign_in user
      visit leagues_path
    end

    context '管理者の場合' do
      given(:user) { FactoryGirl.create :admin }
      scenario 'アクセス可能' do
        expect(page).to have_content 'リーグ一覧'
      end
    end

    context '一般ユーザの場合' do
      given(:user) { create :student }
      scenario 'アクセス不可' do
        expect(page).to have_content 'looking for doesn\'t exist'
      end
    end
  end

  feature 'リーグ登録', js: true do
    given(:user) { create :admin }
    given(:files_path) { "#{Rails.root}/spec/factories/files/" }

    background do
      sign_in user
      visit leagues_path
      click_button '登録'
      wait_for_action
    end

    scenario '新規登録フォームを表示する' do
      within('div#myModal') do
        expect(page).to have_content 'リーグ作成'
      end
    end

    scenario 'リーグを作成する' do
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
      within('div.leagues.list') do
        expect(page).to have_content 'hogeリーグ'
      end
    end
  end
end

