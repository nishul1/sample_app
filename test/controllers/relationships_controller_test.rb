require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  
	test "following should require logged-in user" do
		assert_no_difference 'Relationship.count' do
			post :create			# Post to the create action
		end
		assert_redirected_to login_url	
	end

	test "unfollowing should require logged-in user" do
		assert_no_difference 'Relationship.count' do
			delete :destroy, id: relationships(:one)
		end
		assert_redirected_to login_url
end
