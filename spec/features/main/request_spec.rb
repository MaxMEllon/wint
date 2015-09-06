feature 'マイページへのアクセス' do
  context 'ログインしていない場合' do
    scenario 'ログイン画面に戻される' do
      visit main_mypage_path
      expect(page).to have_content 'ようこそ'
    end
  end

  context 'ログインしている場合' do
    background do
      sign_in create :student
    end

    feature 'マイページへ移動する' do
      context 'プレイヤを選択していない' do
        # error
        # あとで書く
      end

      context 'プレイヤを選択している' do
        background do
          create :league
          player = create :player
          visit main_set_player_path(pid: player.id)
          wait_for_action
        end

        scenario 'マイページへ移動する' do
          expect(page).to have_content '戦略コメント'
        end
      end
    end

  end
end

