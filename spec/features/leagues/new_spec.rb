feature 'リーグ登録' do
  given(:user) { create :admin }

  background do
    login user
    visit leagues_path
    click_button '登録'

    fill_in 'league[name]', with: 'hogeリーグ'
    fill_in 'league[limit_score]', with: '150'
    fill_in 'league[start_at]', with: '2015.09.01 00:00'
    fill_in 'league[end_at]', with: '2015.09.30 00:00'

    fill_in 'rule[change]', with: 7
    fill_in 'rule[take]', with: 5
    fill_in 'rule[try]', with: 10_000

    click_button '作成'
  end

  scenario 'リーグを作成する', js: true do
    expect(page).to have_content 'hogeリーグ'
  end
end

