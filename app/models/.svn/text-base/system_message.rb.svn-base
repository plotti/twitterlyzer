class SystemMessage < ActiveRecord::Base
  
  validates_presence_of :level, :header, :message, :expires
  
  named_scope :global,   :conditions => {:messageable_id => nil}
  named_scope :viewable, lambda { {:conditions => ["dismissed = ? AND expires > ?", false, Time.now]} } 
  
  belongs_to :messageable, :polymorphic => true
  
  def viewable?
    !dismissed? && !expired?
  end
  
  def expired?
    Time.now > expires
  end
  
  def self.add_message(level,header,message)
    SystemMessage.create!(:level => level, :header => Time.now.strftime("%d/%m/%Y %I:%M") + " " + header, :message => message,
                          :expires => Time.now+1.day, :dismissable => true)
  end
end
