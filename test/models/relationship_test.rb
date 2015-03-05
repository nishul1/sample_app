require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
	def setup
		@relationship = relationships(:one)
	end

	test "should be valid" do
		assert @relationship.valid?		
	end

	test "empty follower_id should be invalid" do
		@relationship.follower_id = nil
		assert_not @relationship.valid?
	end

	test "empty followed_id should be invalid" do
		@relationship.follower_id = nil
		assert_not @relationship.valid?
	end
end
