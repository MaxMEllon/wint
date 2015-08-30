require 'spec_helper'

RSpec.describe MainsController, type: :controller do
  describe 'ログイン' do
    scenario '失敗する' do
      visit login_path
      click_on 'ログイン'
      expect(page).to have_content 'ログイン失敗'
    end

    scenario '成功する' do
      visit login_path
      fill_in 'user[snum]', with: 's11t230'
      fill_in 'user[password]', with: 'hoge'
      click_on 'ログイン'
      expect(page).to have_content '分析ページ'
    end
  end
end

