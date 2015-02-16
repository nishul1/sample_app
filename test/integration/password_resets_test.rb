require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
	# Setup.  First ensure the deliveries array is empty
	def setup
		ActionMailer::Base.deliveries.clear
		@user = users(:michael)
	end

	test "password_reset" do
		# Fetch the 'forgot password' form
		get new_password_reset_path
		# Test invalid submission
		post password_resets_path, password_reset: { email: "" }
		assert_template 'password_resets/new'
		# Valid submission
		post password_resets_path, password_reset: { email: @user.email }
		assert_redirected_to root_url
		# Get the user from the create action
		user = assigns(:user)
		follow_redirect!
		assert_select 'div.alert'  # Verify a flash is displayed
		assert_equal 1, ActionMailer::Base.deliveries.size # Verify an email was generated
		# Submit a link with the wrong email
		get edit_password_reset_path(user.reset_token, email: 'wrong_email')
		assert_redirected_to root_url
		# Submit a invalid token in the link URL
		get edit_password_reset_path('wrong token', email: user.email)
		assert_redirected_to root_url
		# Submit a valid combination
		get edit_password_reset_path(user.reset_token, email: user.email)
		assert_template 'password_resets/edit'
		assert_select "input#email[name=email][type=hidden][value=?]", user.email

		# Invalid password & confirmation submitted to the form
		patch password_reset_path(user.reset_token),
			email: user.email,
			user:  {password:   			"foobaz",
				   password_confirmation:  "barquux"}
		# Ensure page is re-rendered with flash warning
		assert_select 'div#error_explanation'
		# Blank password & confirmation
		patch password_reset_path(user.reset_token),
			email: user.email,
			user:  {password:     			"",
					password_confirmation:  ""}
		# Assert our flash is populated, and that the page is re-rendered
		assert_not_nil flash.now
		assert_template 'password_resets/edit'

		# Valid password and confirmation
		patch_via_redirect password_reset_path(user.reset_token),
						   email: user.email,
						   user: {password:    				"foobaz",
						   		  password_confirmation: 	"foobaz"}
		assert_template 'users/show'
	end

	test "expired token" do
		get new_password_reset_path
		post password_resets_path, password_reset: {email: @user.email}
		user = assigns(:user)
		user.update_attribute(:reset_sent_at, 3.hours.ago)
		patch password_reset_path(user.reset_token),
			email: user.email,
			user: {password: 				"foobar",
				   password_confirmation:   "foobar" }
		assert_response :redirect
		follow_redirect!
		assert_match /expired/i, response.body
	end
end