feature 'Access to analysis page' do
  background do
    DatabaseCleaner.clean
    sign_in user
    visit analysis_list_path
  end

  context 'when admin' do
    given(:user) { create :admin }

    scenario 'move to analysis page' do
      expect(page).to have_content '分析ページ'
    end
  end

  context 'when student' do
    given(:user) { create :student }

    scenario 'permission denied' do
      expect(page).to have_content 'looking for doesn\'t exist'
    end
  end
end

