class LogsController < ApplicationController
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  def index
    server = Server.find(params[:server_id])
    @logs = server.logs 
  end

  def show
    server = Server.find(params[:server_id])
    @log = server.logs.find(params[:id])
  end

  def new
    @log = Log.new
  end

  def edit

  end

  def create
    @log = Log.new(script_params)
    if @log.save
      redirect_to @log, notice: 'Log was successfully created.'
    else
      render :new
    end
  end

  def update
    if @log.update(script_params)
      redirect_to @log, notice: 'Log was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @log.destroy
    redirect_to scripts_url, notice: 'Log was successfully destroyed.'
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      @log = Log.find(params[:id])
    end

    def script_params
      params.require(:script).permit(:name, :body, :server_id, :status)
    end
end
