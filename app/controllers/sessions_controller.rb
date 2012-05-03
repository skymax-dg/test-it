class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user.nil? 
      flash.now[:error] = "Invalid EMail/Password combination."
      #flash[:error] = "Invalid EMail/Password combination."
      #redirect_to signin_path # Torna alla pagina di Signin
# !!!! Perchè devo RI-valorizzare la variabile di istanza @title????
      @title = "Sign in"
      render 'new'
    else
      sign_in user
      #redirect_to :action => "show", :id => user.id
      redirect_back_or user # Va alla pagina memorizzata o alla user => UserPage
      #flash[:success] = "Welcome #{user.name} to the Sample App!"
      #redirect_to root_path # Va alla HomePage
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
