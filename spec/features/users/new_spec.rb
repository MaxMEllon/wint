feature 'ユーザ登録' do
  given(:user) { create :admin }

  background do
    login user
    visit users_path
    click_button '登録'

    fill_in 'user[snum]', with: 's00t000'
    fill_in 'user[name]', with: 'ほげ太郎'
    select '信頼・電子情報', from: 'user[depart]'
    select 2012, from: 'user[entrance]'
    select '学生', from: 'user[category]'
    click_button '作成'
  end

  scenario 'ユーザを作成する', js: true do
    expect(page).to have_content 's00t000'
  end
end

