class Record < ActiveRecord::Base
  belongs_to :user

  validates :title, presence: true

  has_attached_file :file_upload, 
  :styles => { 
      :large => "600x600>",
      :medium => "300x300>", 
      :thumb => "100x100>"
    }, 
  :default_url => ":placeholder"
  
  validates_attachment_content_type :file_upload, :content_type => /\Aimage\/.*\Z/
end
