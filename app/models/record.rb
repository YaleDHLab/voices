class Record < ActiveRecord::Base
  print self

  belongs_to :user

  # Before saving the record to the database, manually add a new
  # field to the record that exposes the url where the file is uploaded
  after_save :set_record_upload_url 

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
      "video/quicktime",
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
      "audio/x-mpegaudio",
      "audio/3gpp",
      "application/doc",
      "file/txt",
      "text/plain"
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

  def is_text?
    self.file_upload_file_name =~ %r{\.(docx|doc|pdf|txt)$}i
  end

  # If the uploaded content type is an audio file,
  # return false so that we'll skip audio post processing
  def apply_post_processing?
    if self.is_audio? 
      return false
    
    elsif self.is_text?
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
        :thumb => "200x200>", 
        :medium => "500x500>"
      }
    elsif self.is_video?
      {
        :thumb => { 
          :geometry => "200x200>", 
          :format => 'jpg', 
          :time => 10
        }, 
        :medium => { 
          :geometry => "500x500>", 
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
    elsif self.is_text?
      {}
    else
      {}
    end
  end
  

  def set_record_upload_url
    # if the record is an audio or text file, 
    # set the asset path to the stock audio / text
    # file path in aws, else calculate the asset path
    if self.is_audio?
      if self.file_upload_url != ActionController::Base.helpers.image_path("audio-icon.jpg")
        self.update_attributes(
          :file_upload_url => ActionController::Base.helpers.image_path("audio-icon.jpg")
        )
      end

    elsif self.is_text?
      if self.file_upload_url != ActionController::Base.helpers.image_path("text-file-icon.png")
        self.update_attributes(
          :file_upload_url => ActionController::Base.helpers.image_path("text-file-icon.png")
        )
      end

    else
      record_id_string = self.id.to_s

      # preface the id number with '0' until it's 9 digits long
      while record_id_string.length < 9
        record_id_string = "0" + record_id_string
      end

      # partition the 9 character string into 3 3-digit strings joined by "/"
      id_path = record_id_string.chars.each_slice(3).map(&:join).join("/")

      # construct the full path to the medium size image
      full_image_path = self.file_upload.url(:medium).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 

      # use that sequence to identify the full path to the asset
      if full_image_path != self.file_upload_url
        self.update_attributes(
          :file_upload_url => full_image_path
        )
      end
    end
  end


end