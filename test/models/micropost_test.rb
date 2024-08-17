require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    # @micropost = microposts(:michael_micropost)
    # @user.microposts
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
