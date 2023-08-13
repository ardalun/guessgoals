require 'sidekiq'
require 'sidekiq/web'
Sidekiq::Extensions.enable_delay!

class AdminConstraint
	def matches?(request)
		if request.cookie_jar.encrypted[:admin_id]
			user_is_admin = User.where(id: request.cookie_jar.encrypted[:admin_id]).pluck(:admin).first.present?
		end
		!!user_is_admin
	end
end