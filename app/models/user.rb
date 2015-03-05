class User < ActiveRecord::Base
	has_many :microposts, dependent: :destroy
	has_many :active_relationships, class_name: "Relationship",
									foreign_key: "follower_id",
									dependent: :destroy
	has_many :passive_relationships, class_name: "Relationship",
									 foreign_key: "followed_id",
									 dependent: :destroy
	has_many :following, through: :active_relationships, source: :followed
	has_many :followers, through: :passive_relationships, source: :follower

	attr_accessor :remember_token, :activation_token, :reset_token
	before_save	  :downcase_email
	before_create :create_activation_digest
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 },
					  format: {with: VALID_EMAIL_REGEX },
					  uniqueness: {case_sensitive: false}
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true

	class << self  # Identify that the following methods are CLASS methods.  They are still called via User.digest etc..

		# Class methods that returns the hash digest of the given string
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end

		# Returns a random token - CLASS method
		def new_token
			SecureRandom.urlsafe_base64
		end
	end

	# Places a remember token in user browser to remember user for persistent sessions
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# Check the hash of the appropriate token vs the appropriate digest (eg remember or activation) in the database for persistent sessions
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end
	
	# Activates an account
	def activate
		update_columns(activated: true, activated_at: Time.zone.now)
	end

	# Sends Activation Email
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token # Assign the reset_token
		update_columns(reset_digest: User.digest(reset_token), 
					   reset_sent_at: Time.zone.now) # Update reset email sent at time
	end
	
	# Send the password reset email
	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def feed
		Micropost.where("user_id = ?", id)
	end

	# Follows a user
	def follow(other_user)
		active_relationships.create(followed_id: other_user.id)
	end

	# Unfollows a user - called from follower user object instance
	def unfollow(other_user)
		active_relationships.find_by(followed_id: other_user.id).destroy
	end

	# Checks if the user the function is being called upon is following the other user
	def following?(other_user)
		following.include?(other_user)
	end

	private

		# Converts email to all lower-case
	def downcase_email
		self.email = email.downcase
	end

	# Creates and assigns the activation token and digest
	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end

end
