class AuthenticationsController < ApplicationController
  def index
    @authentications = Authentication.all
  end

  def create
    omniauth = request.env["omniauth.auth"]["info"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    useremail = User.find_by_email(omniauth['email'])
    if authentication
      flash[:notice] = "Signed in Successfully"
      sign_in_and_redirect(:user, authentcation.user)
    elsif useremail 
      flash[:notice] = "Signed in Successfully"
      sign_in_and_redirect(:user, useremail)
    elsif current_user
      current_user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Auth success"
      redirect_to authenticaions_url
    else
      user = User.new
      user.authentications.build(:provider => omniauth['provider'], :uid => ['uid'])
      user.email = omniauth['email']
      user.password = Devise.friendly_token.first(6)
      user.user_name = omniauth['nickname']
      user.save!
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
    end 
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end
end
