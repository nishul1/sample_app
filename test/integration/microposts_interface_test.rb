require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
  	@user = users(:michael)
  end

	test "micropost interface" do
		log_in_as(@user)
		get root_path
		# Verify pagination appears
		assert_select 'div.pagination'
		assert_select 'input[type="file"]'
		# Verify gravatar appears
		assert_select 'img.gravatar'
		# Verify micropost submission form appears
		assert_select 'textarea'
		# Invalid Submission
		post microposts_path, micropost: {content: ""}
		assert_select 'div#error_explanation'
		# Valid Submission
		content = "This micropost really ties the room together"
		picture = fixture_file_upload('test/fixtures/rails.png', 'image.png')
		assert_difference 'Micropost.count', 1 do
			post microposts_path, micropost: {content: content, picture: picture}
		end
		assert assigns(:micropost).picture?,  "No Picture!!"
		follow_redirect!
		assert_match content, response.body
		# Delete a post
		assert_select 'a', 'Delete'
		first_micropost = @user.microposts.paginate(page: 1).first  # Paginate is not necessary?
		assert_difference 'Micropost.count', -1 do
			delete micropost_path(first_micropost)
		end
		# Visit a different user and check delete links don't appear
		get user_path(users(:archer))
		assert_select 'a', { text: 'delete', count: 0 }	
	end

	test "micropost sidebar count" do
		log_in_as(@user)
		get root_path
		assert_match "#{@user.microposts.count} micropost", response.body

		# Users with zero microposts
		other_user = users(:mallory)
		log_in_as(other_user)		# Note how instance variables not required here
		get root_path
		assert_match "0 microposts", response.body
		other_user.microposts.create!(content: "A micropost")
		get root_path
		assert_match "1 micropost", response.body
	end
end
