require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

	def setup
		@user = users(:michael)
		remember(@user)
	end

	test "Verify current_user is set correctly when sessions is nil" do
		assert_equal @user, current_user
		assert is_logged_in?
	end

	test "current_user returns nil when remember digest is wrong" do
		@user.update_attribute(:remember_digest, User.digest(User.new_token))	# Set new token
		assert_nil current_user 			# Runs the current_user method - and checks it returns nil
	end
end