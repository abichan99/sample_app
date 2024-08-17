require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test 'user_id field is required' do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test 'content field is required' do
    @micropost.content = " "
    assert_not @micropost.valid?
  end

  test 'content field is at most 140 alphabets' do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
end
