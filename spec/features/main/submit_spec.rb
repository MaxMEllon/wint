feature '戦略ファイルの提出', js: true do
  shared_context '戦略提出フォームを表示している', state: :main_submit do
    background do
      create :league
      sign_in create :student
      player = create :player
      allow_any_instance_of(League).to receive(:open?).and_return(true)
      visit main_set_player_path(pid: player.id)
      click_button '戦略提出'
      wait_for_action
    end
  end

  context '何も入力していない場合', state: :main_submit do
    background do
      click_button '提出'
      wait_for_action
    end

    scenario '失敗する' do
      expect(page).to have_content '入力してください'
    end
  end

  context '全て入力している場合', state: :main_submit do
    # background do
    #   path = "#{Rails.root}/spec/factories/data/001/source/0001/001/"
    #   within('div#myModal') do
    #     attach_file 'submit[data_dir]', path + 'PokerOpe.c'
    #     fill_in 'submit[comment]', with: 'hoge狙い'
    #     click_button '提出'
    #     wait_for_action
    #   end
    # end

    # scenario '提出履歴に表示が追加される' do
    #   expect(page).to have_content 'hoge狙い'
    # end
  end
end

