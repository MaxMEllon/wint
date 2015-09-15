feature 'リーグの登録', state: :league_list do
  background do
    click_button '登録'
    wait_for_action
  end

  # feature '作成ボタンを押す' do
  #   context '何も入力していない場合' do
  #     background do
  #       click_button '作成'
  #       wait_for_action
  #     end

  #     scenario '失敗する' do
  #       expect(page).to have_content '入力してください'
  #     end
  #   end

  #   context '全て入力している場合' do
  #     scenario 'リーグ一覧に表示が追加される' do
  #       within('div.leagues.list') do
  #         expect(page).to have_content 'hogeリーグ'
  #       end
  #     end

  #     scenario 'データが登録されている' do
  #       league = League.where(name: 'hogeリーグ').first
  #       expect(league.name).to eq 'hogeリーグ'
  #     end
  #   end
  # end
end

