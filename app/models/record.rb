class Record < ActiveRecord::Base
  belongs_to :user

  # ensure user has provided a title for their record
  validates :title, presence: true

  # paperclip processing: store a small, medium, and large copy of images
  # and store a thumb and medium size still of videos
  has_attached_file :file_upload,
    styles: lambda {
      |a| a.instance.is_image? ? {
        :small => "200x200>", 
        :medium => "300x300>", 
        :large => "600x600>"
      } : {
        :thumb => { 
          :geometry => "100x100#", 
          :format => 'jpg', 
          :time => 10
        }, 
        :medium => { 
          :geometry => "300x300#", 
          :format => 'jpg', 
          :time => 10
        }
      }
    },

    processors: lambda { 
      |a| a.is_video? ? [ :ffmpeg ] : [ :thumbnail ] 
    }

  # validate that we accept the type of file the user is uploading
  validates_attachment_content_type :file_upload,
    :content_type => ["video/mp4", "image/jpg", "image/jpeg", "image/png", "image/gif"],
    :message => "Please make sure you've attached a jpg, png, gif, or mp4 file"

  def is_image?
    file_upload.content_type =~ %r(image)
  end

  def is_video?
    file_upload.content_type =~ %r(video)
  end
    
end
