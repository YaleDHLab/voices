class Record < ActiveRecord::Base
  print self

  has_many :record_attachments
  accepts_nested_attributes_for :record_attachments
  
  # Ensure user has provided the required fields
  validates :title, presence: true
  validates :description, presence: true
  validates :release_checked, presence: true
  
end