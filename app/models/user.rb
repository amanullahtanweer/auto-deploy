class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :servers
  has_many :memberships
  has_many :charges


  def servers 
    owner       = Server.where(owner: self)
    memberships = Server.joins(:memberships)
      .where(memberships: { user_id: id })

    Server.from("(#{memberships.to_sql} UNION #{owner.to_sql}) AS servers")
  end


  def member?(server)
    Server.joins(:memberships)
      .exists?(memberships: { user_id: id, server_id: server.id })
  end


  def server_admin?(server)
    Server.joins(:memberships)
      .exists?(memberships: { user_id: id, server_id: server.id, role: "admin" })
  end


  def owner?(server)
    server.owner == self
  end

  def subscribed?
		stripe_subscription_id?
	end
	
end
