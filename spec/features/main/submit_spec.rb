feature '戦略の提出', js: true, state: :main_mypage do
  background do
    click_button '戦略提出'
    wait_for_action
  end

  # context '何も入力していない場合' do
  #   background do
  #     click_button '提出'
  #     wait_for_action
  #   end

  #   scenario '失敗する' do
  #     expect(page).to have_content '入力してください'
  #   end
  # end

  context '全て入力している場合' do
    background do
      path = "#{Rails.root}/spec/factories/data/001/source/0001/001/"
      fill_in 'submit[data_dir]', with: File.read(path + 'PokerOpe.c')
      fill_in 'submit[comment]', with: 'hoge狙い'
      click_button '提出'
      wait_for_action
    end

    scenario '提出履歴に表示が追加される' do
      expect(page).to have_content 'hoge狙い'
    end

    scenario 'ステータスが成功になる' do
      expect(page).to have_content '成功'
    end
  end
end

