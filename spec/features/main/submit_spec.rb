feature '戦略の提出', js: true, state: :main_mypage do
  def submit(filename)
    path = "#{Rails.root}/spec/factories/data/001/source/0001/001/"
    fill_in 'submit[data_dir]', with: File.read(path + filename)
    click_button '提出'
    wait_for_action(1.0)
  end

  background do
    click_button '戦略提出'
    wait_for_action
  end

  context '何も入力していない場合' do
    pending
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

  context '正しい戦略を提出した場合' do
    background { submit 'success.c' }

    scenario '成功と表示される' do
      expect(page).to have_content '成功'
    end
  end

  context 'コンパイルエラーとなる戦略を提出した場合' do
    background { submit 'compile_error.c' }

    scenario 'コンパイルエラーと表示される' do
      expect(page).to have_content 'コンパイルエラー'
    end
  end

  context '実行時エラーとなる戦略を提出した場合' do
    background { submit 'execute_error.c' }

    scenario '実行時エラーと表示される' do
      expect(page).to have_content '実行時エラー'
    end
  end

  context 'シンタックスエラーとなる戦略を提出した場合' do
    background { submit 'syntax_error.c' }

    scenario '危険なコードと表示される' do
      expect(page).to have_content '危険なコード'
    end
  end

  context '時間超過となる戦略を提出した場合' do
    background do
      stub_const("Rule::TIME_LIMIT", 0.1)
      submit 'time_error.c'
    end

    scenario '時間超過と表示される' do
      expect(page).to have_content '時間超過'
    end
  end
end

