require 'spec_helper'

RSpec.feature MainsController, type: :feature do
  background do
    visit login_path
  end

  feature '失敗する' do
    click_on 'ログイン'
    expect(page).to have_content 'ログイン失敗'
  end

  feature '成功する' do
    scenario '管理者の場合' do
      given(:user) { create :admin }
      fill_in 'user[snum]', with: user.snum
      fill_in 'user[password]', with: user.password
      click_on 'ログイン'
      expect(page).to have_content '分析ページ'
    end
  end

  #  it '学生の場合' do
  #    given(:user) { create :student }
  #    fill_in 'user[snum]', with: user.snum
  #    fill_in 'user[password]', with: user.password
  #    click_on 'ログイン'
  #    expect(page).to have_content 'hoge'
  #  end
  #end
end

