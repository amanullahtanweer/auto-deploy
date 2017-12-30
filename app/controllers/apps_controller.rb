class AppsController < ApplicationController
  before_action :set_app, only: [:show, :edit, :update, :destroy]

  def index
    @server = Server.find(params[:server_id])
    @apps = @server.apps 
  end

  def show
  end

  def deploy
    @app = App.find(params[:app_id])
    AppDeployJob.perform_later(@app)
    redirect_to server_app_path(params[:server_id],params[:app_id])
  end

  def new
    @server = Server.find(params[:server_id])
    @app = App.new
  end

  def edit

  end

  def rails_logs 
    @app = App.find(params[:app_id])
    @server = @app.server
  end

  def create
    @app = App.new(app_params)
    @app.server_id = params[:server_id]
    if @app.save
      redirect_to server_apps_url, notice: 'App was successfully created.'
    else
      render :new
    end
  end

  def update
    if @app.update(app_params)
      redirect_to server_app_url(@server,@app), notice: 'App was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @app.destroy
    redirect_to server_apps_url, notice: 'Log was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @server = Server.find(params[:server_id])
      @app = App.find(params[:id])
    end

    def app_params
      params.require(:app).permit(:server_id, :name, :repo_url, :branch, :domain, :env_vars, :pg_status, :redis_status, :clone_status, :deploy_status, :nginx_ssl, :domain)
    end
end
