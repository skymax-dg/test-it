require "lib/excel.rb"

class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => [:destroy]

  def export_users_xls
    @users = User.find(:all, :order => :name)
    fname = "#{$Init[:path][:path_file_xls]}\\UserList.xls"
    process_spreadsheet(fname) do |f|
      process_worksheet(f, "Elenco Utenti", %w[Codice Nominativo E-Mail], [10, 30, 30]) do |w|
        # Contatore di riga (segnariga)
        i = 1
        # Ciclo per ogni elemento dell'array @users'
        @users.each do |user|
          # valorizzo le colonne della riga rowcount
          w.row(i).push user.id, user.name, user.email 
          # Incremento rowcount per il prossimo giro 
          i += 1
        end
      end
    end
    redirect_back_or root_path
  end
      
  def exp_posts_by_user_xls
    begin
      @user = User.find(params[:id])
      fname = "#{$Init[:path][:path_file_xls]}\\UsersPosts_FollowedBy_#{@user.name}_id_#{@user.id.to_s}#{Time.now.strftime("%Y_%m_%d-%H_%M_%S")}.xls"
      # Istanza oggetto xls
      process_spreadsheet(fname) do |f|
        # il metodo following restituisce un array di tutti gli utenti seguiti da @user ovvero che @user sta seguendo
        # Ciclo per ogni utente seguito
        @user.following.each do |followeduser|
          # Istanzio un oggetto sheet per ogni utente seguito
          process_worksheet(f, "#{followeduser.name}_id_#{followeduser.id.to_s}", %w[Inserito_il Commento], [20, 60]) do |w|
            # Contatore di riga (segnariga)
            i = 1
            # Ciclo per ogni elemento dell'array microposts'
            followeduser.microposts.each do |p|
              # valorizzo le colonne della riga rowcount
              w.row(i).push p.created_at, p.content
              # Incremento rowcount per il prossimo giro 
              i += 1
            end
          end
        end
      end
      redirect_back_or root_path
    rescue Exception => error
      flash[:error] = "#{fname} ERRORE ! ! !  --  Formato file di configurazione non corretta. #{error}"
      redirect_back_or root_path
    end
  end

  def exp_posts_by_user_pdf
#    @user = User.find(params[:id])
#    @feeditems = @user.feed 
#    table = @feeditems.report_table(
    table = User.find(params[:id]).feed.report_table(
              :all,
              :include => {:user => {:only => "name"}},
              :only => ["user.name", "created_at", "content"],
              :order => {"user_name", "created_at"},
              :transforms => lambda {|r| r["created_at"] = "#{(r["created_at"].strftime("%d/%m/%Y %H:%M:%S"))}" }
                                   )
    grouping = Grouping(table, :by => "user.name")
    send_data grouping.to_pdf,
      :type => "application/pdf",
      :disposition => "inline",
      :filename => "PostsByUser.pdf"
  end

  def export_users_pdf
    table = User.report_table(:all, :only => %w[name email])
    sorted_table = table.sort_rows_by("name", :order => :ascending)
    send_data sorted_table.to_pdf,
      :type => "application/pdf",
      :disposition => "inline",
      :filename => "Users.pdf"
  end

  def export_posts_pdf
    @user = User.find(params[:id])
    table = @user.microposts.report_table(
              :all, 
              :include => {:user => {:only => "name"}},
              :only => ["user.name", "created_at", "content"],
              :order => "created_at",
              :transforms => lambda {|r| r["created_at"] = "#{(r["created_at"].strftime("%d/%m/%Y %H:%M:%S"))}" }
                                          )
    table.rename_columns("user.name" => "Autore",
                         "created_at" => "Inserito il",
                         "content" => "Commento")
    grouping = Grouping(table, :by => "Autore")
    send_data grouping.to_pdf,
      :type => "application/pdf",
      :disposition => "inline",
      :filename => "UserPosts.pdf"
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
    store_location
  end

  def edit
    #@user = User.find(params[:id]) find già fatto nella correct_user
    @title = "Edit user"
  end

  def update
    #@user = User.find(params[:id]) find già fatto nella correct_user
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to user_path
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
#    @users = User.all #oppure User.find(:all)
    store_location
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deestroyed."
    redirect_to users_path
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path, 
                  :notice => "User signed in does't match" unless current_user?(@user) 
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
