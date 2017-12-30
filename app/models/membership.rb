class Membership < ApplicationRecord
	belongs_to :server
	belongs_to :member, class_name: 'User', foreign_key: :user_id

	enum role: %i(reader writer admin), _prefix: true

	validates :server_id, uniqueness: { scope: :user_id }

end
