feature 'リーグ編集' do
  given(:user) { create :admin }
  given(:league) { build :league }
  given(:files_path) { "#{Rails.root}/spec/factories/files/" }

  background do
    login user
    create_league(league)
    visit leagues_path
    click_button '編集'

    fill_in 'league[name]', with: 'edit_hogeリーグ'
    fill_in 'league[limit_score]', with: '200'
    fill_in 'league[start_at]', with: '2016.09.01 00:00'
    fill_in 'league[end_at]', with: '2016.09.30 00:00'
    fill_in 'rule[change]', with: 6
    fill_in 'rule[take]', with: 6
    fill_in 'rule[try]', with: 10_000
    click_button '更新'
  end

  scenario 'リーグを編集する', js: true do
    expect(page).to have_content 'edit_hogeリーグ'
    expect(page).to have_content '06-06-10000'
  end
end

