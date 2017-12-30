class ScriptsController < ApplicationController
  before_action :set_script, only: [:show, :edit, :update, :destroy]

  def index
    @q = Script.all.ransack(params[:q])
    @scripts = @q.result.page(params[:page])
  end

  def show
    
  end

  def new
    @script = Script.new
  end

  def edit

  end

  def create
    @script = Script.new(script_params)
    @script.user_id = current_user.id
    if @script.save
      redirect_to @script, notice: 'Script was successfully created.'
    else
      render :new
    end
  end

  def update
    if @script.update(script_params)
      redirect_to @script, notice: 'Script was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @script.destroy
    redirect_to scripts_url, notice: 'Script was successfully destroyed.'
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_script
      @script = Script.find(params[:id])
    end

    def script_params
      params.require(:script).permit(:name, :body, :user_id)
    end
end
