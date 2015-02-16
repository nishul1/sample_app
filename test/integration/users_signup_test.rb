require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
	def setup
		ActionMailer::Base.deliveries.clear
		@user1 = users(:michael)
	end

	test "invalid signup information" do
		get signup_path
		assert_no_difference 'User.count' do
			post users_path, user: {name: "",
									email: "user@invalid",
									password: "foo",
									password_confirmation: "bar"}
		end
		assert_template 'users/new'
		assert_select 'div#error_explanation'
		assert_select 'div.field_with_errors'
		assert_select "li", text: "Name can't be blank"
	end

	test "valid signup information with account activation" do
		get signup_path
		assert_difference 'User.count', 1 do
			post users_path, user: { 	name: "Example User",
													email: "user@example.com",
													password: "password", 
													password_confirmation: "password"}
			end
		assert_equal 1, ActionMailer::Base.deliveries.size
		user = assigns(:user)  # Ensure we can access @user from the create action to access the virtual activation_token attribute
		assert_not user.activated?	# Ensure the user is not activated after submitting user creation details

		# Ensure unactivated user can't log in
		log_in_as(user)
		assert_not is_logged_in?

		# Index page
		log_in_as(@user1)
		get users_path
		assert_template 'users/index'
		assert_no_match user.name, response.body
		delete logout_path
		assert_not is_logged_in?


		# Profile page
		get user_path(user)
		assert_redirected_to root_url


		# Ensure user isn't activated and logged in with invalid token
		get edit_account_activation_path("invalid_token")
		assert_not is_logged_in?
		# Ensure user isn't activated and logged in with valid token but invalid email		
		get edit_account_activation_path(user.activation_token, email: 'wrong')
		assert_not is_logged_in?

		# Ensure user isn activated and logged in with valid token and email
		get edit_account_activation_path(user.activation_token, email: user.email)
		assert user.reload.activated?
		follow_redirect!
		assert_template 'users/show'
		assert is_logged_in?
	end
end