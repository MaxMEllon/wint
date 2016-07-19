shared_examples_for 'アクセス不可' do
  scenario '404へ移動する' do
    expect(page).to have_content 'looking for doesn\'t exist'
  end
end

