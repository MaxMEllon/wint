module LoginHelper
  def login(user)
    visit login_path
    fill_in 'user[snum]', with: user.snum
    fill_in 'user[password]', with: user.password
    click_on 'ログイン'
  end
end

