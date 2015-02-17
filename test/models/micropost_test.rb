require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
	def setup
		@user = users(:michael)
		@micropost = @user.microposts.build(content: "Lorem Ipsum")
	end

	test "micropost should be valid" do
		assert @micropost.valid?
	end

	test "user id should be present" do
		@micropost.user_id = nil
		assert_not @micropost.valid?
	end

	test "order should be most recent first" do
		assert_equal Micropost.first, microposts(:most_recent)
	end

	test "content should be not be whitespace" do
		@micropost.content = " "
		assert_not @micropost.valid?
	end

	test "content shouldn't be empty" do
		@micropost.content = ""
		assert_not @micropost.valid?
	end

	test "content shouldn't be more than 140 characters" do
		@micropost.content = "a" * 141
		assert_not @micropost.valid?
	end


end
