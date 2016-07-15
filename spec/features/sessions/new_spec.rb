feature 'ログイン' do
  background do
    visit login_path
  end

  context '何も入力していない場合' do
    background do
      click_on 'ログイン'
    end

    scenario '失敗する' do
      expect(page).to have_content 'ログイン失敗'
    end
  end

  context '入力している場合' do
    background do
      fill_in 'user[snum]', with: user.snum
      fill_in 'user[password]', with: user.password
      click_on 'ログイン'
    end

    context '管理者の場合' do
      let(:user) { create :admin }
      scenario '分析ページヘ移動する' do
        expect(page).to have_content '分析ページ'
      end
    end

    context '一般ユーザの場合' do
      let(:user) { create :student }
      scenario 'プレイヤ選択ページヘ移動する' do
        expect(page).to have_content 'プレイヤ選択'
      end
    end
  end
end

