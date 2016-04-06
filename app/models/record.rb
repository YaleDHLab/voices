class Record < ActiveRecord::Base
  belongs_to :user

  # ensure user has provided a title for their record
  validates :title, presence: true

  # paperclip processing: store a small, medium, and large copy of images
  # and store a thumb and medium size still of videos
  has_attached_file :file_upload,
    styles: lambda { |a| a.instance.check_file_type },

    processors: lambda { 
      |a| a.is_video? ? [ :ffmpeg ] : [ :thumbnail ] 
    }

  # validate that we accept the type of file the user is uploading
  validates_attachment_content_type :file_upload,
    :content_type => [
      "video/mp4", 
      "image/jpg", 
      "image/jpeg", 
      "image/png", 
      "image/gif",
      "audio/mpeg", "audio/x-mpeg", "audio/mp3", "audio/x-mp3", "audio/mpeg3", "audio/x-mpeg3", "audio/mpg", "audio/x-mpg", "audio/x-mpegaudio"
      ],
    :message => "Please make sure you've attached a jpg, png, gif, or mp4 file"

    before_post_process :skip_for_audio

  # helper method that uses the =~ regex helper to see if 
  # the current file_upload has a content_type 
  # attribute that contains the string "image" / "video", or "audio"
  def is_image?
    file_upload.content_type =~ %r(image)
  end

  def is_video?
    file_upload.content_type =~ %r(video)
  end

  def is_audio?
    file_upload.content_type =~ /\Aaudio\/.*\Z/
  end


  # if the uploaded content type is found in the explicit array of audio types, 
  # return false so that we'll skip audio post processing
  def skip_for_audio
    if is_audio? 
      return false
    else
      return true
    end
  end

  def check_file_type
    if is_image?
      {
        :small => "200x200>", 
        :medium => "300x300>", 
        :large => "600x600>"
      }
    elsif is_video?
      {
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
    elsif is_audio?
      {
        :audio => {
          :format => "mp3"
        }
      }
    else
      {}
    end
  end
    
end
