class Micropost < ActiveRecord::Base
  acts_as_reportable
  attr_accessible :content

  validates :content, :presence => true,
                      :length => {:maximum => 140}
  validates :user_id, :presence => true

  belongs_to :user
  
  
  default_scope :order => 'microposts.created_at DESC'
  
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  private
  
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id)
      where("user_id IN (#{followed_ids}) OR user_id = :user_id", { :user_id => user})
    end
end
