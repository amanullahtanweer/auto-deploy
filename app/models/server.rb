class Server < ApplicationRecord
	belongs_to :owner, class_name: 'User', foreign_key: :user_id

	has_many :memberships, dependent: :destroy
	has_many :members, through: :memberships
	
	has_many :logs, dependent: :destroy
	has_many :apps, dependent: :destroy
end
