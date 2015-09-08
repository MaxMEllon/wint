shared_context 'リーグ登録のモーダルを表示している', state: :league_new do
  background do
    sign_in create :admin
    visit leagues_path
    click_button '登録'
    wait_for_action
  end
end

shared_context 'リーグを登録している', state: :league_create do
  background do
    files_path = "#{Rails.root}/spec/factories/data/001/rule/"

    fill_in 'league[name]', with: 'hogeリーグ'
    fill_in 'league[limit_score]', with: '150'
    fill_in 'league[start_at]', with: '2015.09.01 00:00'
    fill_in 'league[end_at]', with: '2015.09.30 00:00'
    attach_file 'file[stock]', files_path + 'Stock.ini'
    attach_file 'file[header]', files_path + 'Poker.h'
    attach_file 'file[exec]', files_path + 'PokerExec.c'
    attach_file 'file[card]', files_path + 'CardLib.c'
    fill_in 'rule[change]', with: 7
    fill_in 'rule[take]', with: 5
    fill_in 'rule[try]', with: 10000
    click_button '作成'
    wait_for_action
  end
end

shared_context 'モーダルを表示してリーグを登録している', state: :league_new_and_create do
  include_context 'リーグ登録のモーダルを表示している', state: :league_new
  include_context 'リーグを登録している', state: :league_create
end

