class Record < ActiveRecord::Base
  has_attached_file :file_upload, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :file_upload, :content_type => /\Aimage\/.*\Z/
end
