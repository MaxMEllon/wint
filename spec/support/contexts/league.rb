shared_context 'リーグ一覧画面を表示している', state: :league_list do
  background do
    sign_in create :admin
    visit leagues_path
  end
end

