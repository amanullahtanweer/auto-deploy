class Admin::UsersController < Admin::ApplicationController
	before_action :user, except: [:index, :new, :create]
	before_action :set_roles

	def index
    @q = User.ransack(params[:q])
    @users = @q.result.page(params[:page])
	end

  def show
  end

  def new
    @user = User.new
  end


  def edit
  end


  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_url, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to edit_admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

    def user
      @user = User.find(params[:id])
    end

    def default_route
    	[:admin, @user]
  	end

    def set_roles 
    	@roles = Role.all if current_user.has_role? :admin
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation,:role_ids => [])
    end

end
