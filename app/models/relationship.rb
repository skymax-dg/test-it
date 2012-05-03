class Relationship < ActiveRecord::Base

  attr_accessible :followed_id
  attr_accessible :follower_id

  # Definisce la relazione 1a1 con la classe "User"
  # tramite :follower (follower_id)
  # e la chiave primaria della classe "User" (id)  
  belongs_to :follower, :class_name => "User"
  # Definisce la relazione 1a1 con la classe "User"
  # tramite :followed (followed_id)
  # e la chiave primaria della classe "User" (id)  
  belongs_to :followed, :class_name => "User"
  
  validates :follower_id, :presence => true
  validates :followed_id, :presence => true
end
