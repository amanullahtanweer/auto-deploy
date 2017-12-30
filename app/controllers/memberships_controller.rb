class MembershipsController < ApplicationController
	before_action :authenticate_user!

	before_action :set_server
	before_action :set_membership, only: :destroy


	def index
		# Users without owner and members of this team
		@users = User.where.not(id: @server.owner.id)
			.where.not(id: @server.members.pluck(:id))

		@members = User.select('users.*, memberships.role')
			.joins(:memberships)
			.where(memberships: { server_id: @server.id })
	end

	def create
		@membership = Membership.new(membership_params)

		if @membership.save
			redirect_to server_memberships_path(@server), notice: 'Server has been successfully created.'
		else
			flash.now[:alert] = @membership.errors.full_messages.first
			redirect_to server_memberships_path(@server)
		end
	end

	def destroy
		@membership.destroy

		redirect_to server_memberships_path(@server), notice: 'Server has been successfully deleted.'
	end

	private

	def membership_params
		params.permit(:server_id, :user_id, :role)
	end

	def set_membership
		@membership = Membership.find_by(
			server_id: params[:server_id],
			user_id: params[:user_id]
		)
	end

	def set_server
		@server = Server.find(params[:server_id])
	end
end

