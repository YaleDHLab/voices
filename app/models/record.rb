class Record < ActiveRecord::Base
  belongs_to :user

  # Before saving the record to the database, manually add a new
  # field to the record that exposes the url where the file is uploaded
  before_save { |record| record.file_upload_url = record.file_upload.url }

  # Ensure user has provided the required fields
  validates :title, presence: true
  validates :file_upload, presence: true
  validates :description, presence: true
  validates :metadata, presence: true
  validates :hashtag, presence: true
  validates :release_checked, presence: true

  # Use the has_attached_file method to add a file_upload property to the Record
  # class. 
  has_attached_file :file_upload,
    # In order to determine the styles of the image we want to save
    # e.g. a small style copy of the image, plus a large style copy
    # of the image, call the check_file_type method
    styles: lambda { |a| a.instance.check_file_type },

    processors: lambda { 
      |a| a.is_video? ? [ :ffmpeg ] : [ :thumbnail ] 
    }

  # Validate that we accept the type of file the user is uploading
  # by explicitly listing the mimetypes we are willing to accept
  validates_attachment_content_type :file_upload,
    :content_type => [
      "video/mp4", 
      "image/jpg", 
      "image/jpeg", 
      "image/png", 
      "image/gif",
      "audio/mpeg", 
      "audio/x-mpeg", 
      "audio/mp3", 
      "audio/x-mp3", 
      "audio/mpeg3", 
      "audio/x-mpeg3", 
      "audio/mpg", 
      "audio/x-mpg", 
      "audio/x-mpegaudio"
      ],
    :message => "Please make sure you've attached a jpg, png, gif, or mp4 file"

  # Before applying the Imagemagick post processing to this record
  # check to see if we indeed wish to process the file. In the case
  # of audio files, we don't want to apply post processing
  before_post_process :apply_post_processing?


  # Helper method that uses the =~ regex method to see if 
  # the current file_upload has a content_type 
  # attribute that contains the string "image" / "video", or "audio"
  def is_image?
    self.file_upload.content_type =~ %r(image)
  end

  def is_video?
    self.file_upload.content_type =~ %r(video)
  end

  def is_audio?
    self.file_upload.content_type =~ /\Aaudio\/.*\Z/
  end

  # If the uploaded content type is an audio file,
  # return false so that we'll skip audio post processing
  def apply_post_processing?
    if self.is_audio? 
      return false
    else
      return true
    end
  end

  # Method to be called in order to determine what styles we should
  # save of a file.
  def check_file_type
    if self.is_image?
      {
        :small => "200x200>", 
        :medium => "300x300>", 
        :large => "600x600>"
      }
    elsif self.is_video?
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
    elsif self.is_audio?
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
