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

