# frozen_string_literal: true

# Controller for managing users in the administration namespace.
module Administration
  class UsersController < ApplicationController
    # GET /administration/users
    def index
      @users = User.page(params[:page])
    end

    # GET /administration/users/:id
    def show
      @user = User.find(params[:id])
    end

    # GET /administration/users/new
    def new
      @user = User.new
    end

    # POST /administration/users
    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to administration_user_path(@user), notice: 'User was successfully created.'
      else
        render :new
      end
    end

    # GET /administration/users/:id/edit
    def edit
      @user = User.find(params[:id])
    end

    # PATCH/PUT /administration/users/:id
    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to administration_user_path(@user), notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /administration/users/:id
    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to administration_users_path, notice: 'User was successfully deleted.'
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
end
