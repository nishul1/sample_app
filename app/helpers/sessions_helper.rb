module SessionsHelper

	def log_in(user)	#Logs in the given user
		session[:user_id] = user.id
	end

	# Remembers a user for a persistent session
	def remember(user)
		user.remember  # Invokes the 'remember' INSTANCE method - creating and storing into the DB the hashed remember_token
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	def current_user
		if (user_id = session[:user_id])		# Checks to see if user is logged in temporarily by checking for existence of session cookie
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id])    # Checks to see if user is logged in permanently by checking for existence of persistent signed cookie
			#raise	#If the tests still pass, this branch is currently untested...
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])   # Check that hash of remember token in browser matches remember_digest stored in the browser
				log_in user
				@current_user = user
			end
		end
	end

	def logged_in?
		!current_user.nil?
	end

	# Forgets a persistent session
	def forget(user)
		user.forget 		# Calls the USER CLASS method 'forget' to set remember_digest to nil
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	#Logs a user out
	def log_out
		forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end

	def current_user?(user)
		user == current_user
	end

	# Redirects to stored location (or default) based on previous get request
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	# Stores URL trying to be accessed
	def store_location
		session[:forwarding_url] = request.url if request.get?
	end

end