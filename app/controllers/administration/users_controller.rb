# frozen_string_literal: true

# Controller for managing users in the administration namespace.
module Administration
  class UsersController < ApplicationController
    before_action :authenticate_user!
    # GET /administration/users
    def index
      @q = User.ransack(params[:q])
      @users = @q.result.page(params[:page]).order(created_at: :desc)
      authorize @users
    end

    # GET /administration/users/:id
    def show
      @user = User.find(params[:id])
      authorize @user
    end

    # GET /administration/users/new
    def new
      @user = User.new
      authorize @user
    end

    # POST /administration/users
    def create
      @user = User.new(user_params)
      authorize @user

      if @user.save
        redirect_to administration_user_path(@user), notice: 'User was successfully created.'
      else
        render :new
      end
    end

    # GET /administration/users/:id/edit
    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    # PATCH/PUT /administration/users/:id
    def update
      @user = User.find(params[:id])
      authorize @user
      filtered_params = user_params.to_h.symbolize_keys
      if filtered_params[:password].blank?
        filtered_params.delete(:password)
        filtered_params.delete(:password_confirmation)
      end
      if @user.update(filtered_params)
        redirect_to administration_user_path(@user), notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /administration/users/:id
    def destroy
      @user = User.find(params[:id])
      authorize @user
      @user.destroy
      redirect_to administration_users_path, notice: 'User was successfully deleted.'
    end

    private

    def user_params
      permitted = %i[full_name email phone role password password_confirmation]
      params.require(:user).permit(permitted)
    end
  end
end
