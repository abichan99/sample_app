require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    @user = users(:michael)    
  end

  test 'profile display' do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    
    # ユーザー情報表示画面
    assert_select '.user_info>h1', @user.name
    assert_select '.user_info>h1', @user.name
    assert_select '.user_info>h1>img.gravatar'
    
    # マイクロポスト表示画面
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
