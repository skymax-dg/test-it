require 'digest'
class User < ActiveRecord::Base
  acts_as_reportable
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  has_many :microposts, :dependent => :destroy
  
  # definisce una relazione 1aN col la classe relationship(:relationships)
  # tramite l'attributo "follower_id"
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy  
  # definisce una relazione 1aN col la classe relationship(:relationships)
  # tramite l'attributo "followed_id"
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship"#,
                                   #:dependent => :destroy
  # definisce un array (following) tramite relationship(:relationships)
  # di defaul cercherebbe su relationship id_following quindi è necessario specificare
  # :source in modo che si agganci a id_followed
  has_many :following, :through => :relationships, :source => :followed
  # in questo caso :source non serve perche :followers viene tradotto in id_follower  
  has_many :followers, :through => :reverse_relationships  
  
  email_rejex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
                   :length => {:maximum => 50}
  
  validates :email, :presence => true,
  					        :format => {:with => email_rejex},
					          :uniqueness => {:case_sensitive => false}

  validates :password, :presence => true,
  					           :confirmation => true,
					             :length => {:within => 6..40}

  before_save :encrypt_password
  
  def feed
#    Micropost.where("user_id = ?", id)
    Micropost.from_users_followed_by(self)
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    self.relationships.create(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end


  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
  	encrypted_password == encrypt(submitted_password)
  	#Compare encrypted_password with the encrypted version of submitted_password
  end
  
  # Return user if the submitted password and email match with db information.
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil? # user not found 
    return user if user.has_password?(submitted_password) # Password match
    # return nil otherwise
    #I 3 return commentati sopra possono essere sostituiti con l'istruzione seguente
    user && user.has_password?(submitted_password) ? user : nil
  end

  # Check the link between id and cockie_salt
  def self.authenticate_with_salt(id, coockie_salt)
    user = find_by_id(id)
    #user = find(id)
# L'istruzione sopra darebbe errore in caso di id = nil    
    #return nil if user.nil? # user not found 
    #return user if user.salt == coockie_salt
    # return nil otherwise
    #I 3 return commentati sopra possono essere sostituiti con l'istruzione seguente
    (user && user.salt == coockie_salt) ? user : nil
  end

  private
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
	  end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

