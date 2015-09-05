feature 'ログイン' do
  context '何も入力していない場合' do
    scenario '失敗する' do
      visit login_path
      click_on 'ログイン'
      expect(page).to have_content 'ログイン失敗'
    end
  end

  context '管理者の場合' do
    let(:user) { create :admin }
    scenario '分析ページヘ移動する' do
      sign_in user
      expect(page).to have_content '分析ページ'
    end
  end

  context '一般ユーザの場合' do
    let(:user) { create :student }
    scenario 'プレイヤ選択ページヘ移動する' do
      sign_in user
      expect(page).to have_content 'プレイヤ選択'
    end
  end
end

