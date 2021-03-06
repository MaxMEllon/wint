feature 'プレイヤ一覧ページへのアクセス' do
  background do
    login user
    visit players_path
  end

  context '管理者の場合' do
    given(:user) { create :admin }
    scenario 'アクセス可能' do
      expect(page).to have_content 'プレイヤ一覧'
    end
  end

  context '一般ユーザの場合' do
    given(:user) { create :student }
    it_should_behave_like 'アクセス不可'
  end
end

