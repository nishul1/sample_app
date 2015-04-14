require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:michael)
	end

	test "profile display" do
		get user_path(@user)
		assert_select 'title', full_title(@user.name)
		assert_match @user.name, response.body
		assert_select 'img.gravatar'
		assert_match @user.microposts.count.to_s, response.body
		assert_select 'div.pagination'
		@user.microposts.paginate(page: 1).each do |micropost|
			assert_match micropost.content, response.body
		end
	end

	test "stats count check" do
		log_in_as(@user)
		get root_path
		assert_select 'a[href=?]', following_user_path(@user)
		assert_select 'a[href=?]', followers_user_path(@user)
		assert_select '#followers', @user.followers.count.to_s
		assert_select '#following', @user.following.count.to_s

	end

end
