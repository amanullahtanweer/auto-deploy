class ServersController < ApplicationController
  before_action :set_server, only: [:show, :edit, :update, :destroy]

  def index
    @q = current_user.servers.ransack(params[:q])
    @servers = @q.result.page(params[:page])
  end

  def retry
    @server = Server.find(params[:server_id])
    ServerDeployJob.perform_later(@server)
    redirect_to @server
  end

  def nginx_logs 
    @server = Server.find(params[:server_id])
  end
  
  def show
  end

  def new
    redirect_to pricing_path, notice: "You do not have any active subscription" unless current_user_subscribed?
    @server = Server.new
  end

  def edit
  end

  def create
    @server = Server.new(server_params)
    @server.user_id = current_user.id
    if @server.save
      redirect_to @server, notice: 'Server was successfully created.'
    else
      render :new
    end
  end

  def update
    if @server.update(server_params)
      redirect_to @server, notice: 'Server was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @server.destroy
    redirect_to servers_url, notice: 'Server was successfully destroyed.'
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_server
      @server = Server.find(params[:id])
    end

    def server_params
      params.require(:server).permit(:name, :public_ip, :domain, :user_id)
    end
end
