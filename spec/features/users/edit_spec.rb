feature 'ユーザ編集' do
  given(:user) { create :admin }

  background do
    login user
    visit users_path
    click_button '編集'

    fill_in 'user[snum]', with: 's99t999'
    fill_in 'user[name]', with: 'edit_ほげ太郎'
    select '教授者', from: 'user[category]'
    click_button '更新'
  end

  scenario 'ユーザを編集する', js: true do
    expect(page).to have_content 'edit_ほげ太郎'
  end
end

