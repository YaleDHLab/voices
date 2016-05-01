class RecordAttachment < ActiveRecord::Base
  print "record attachment", self

  belongs_to :record

  validates :file_upload, presence: true

  # Before saving the record to the database, manually add a new
  # field to the record that exposes the url where the file is uploaded
  after_save :set_remote_urls, :set_media_type

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
      "application/pdf",

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
      
      "file/txt",
      "text/plain",

      "application/doc",
      "application/msword", 
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template",
      "application/vnd.ms-word.document.macroEnabled.12",
      "application/vnd.ms-word.template.macroEnabled.12",
      

      "application/vnd.ms-excel",     
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",

      "application/vnd.ms-powerpoint",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "application/vnd.openxmlformats-officedocument.presentationml.template",
      "application/vnd.openxmlformats-officedocument.presentationml.slideshow",
      "application/vnd.ms-powerpoint.addin.macroEnabled.12",
      "application/vnd.ms-powerpoint.presentation.macroEnabled.12",
      "application/vnd.ms-powerpoint.template.macroEnabled.12",
      "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
      ],
    :message => "Sorry! We only accept the following filetypes: mp4, quicktime, jpg, png, gif, mp3, and txt"

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

  def is_plain_text?
    self.file_upload_file_name =~ %r{\.(txt)$}i
  end

  def is_excel?
    self.file_upload_file_name =~ %r{\.(xls|xlt|xla|xlsx|xlsm|xltx|xltm|xlsb|xlam|csv|tsv)$}i
  end

  def is_word_document?
    self.file_upload_file_name =~ %r{\.(docx|doc|dotx|docm|dotm)$}i
  end

  def is_powerpoint?
    self.file_upload_file_name =~ %r{\.(pptx|ppt|potx|pot|ppsx|pps|pptm|potm|ppsm|ppam)$}i
  end

  def is_pdf?
    self.file_upload_file_name =~ %r{\.(pdf)$}i
  end

  def has_default_image?
    is_audio?
    is_plain_text?
    is_excel?
    is_word_document?
  end

  # If the uploaded content type is an audio file,
  # return false so that we'll skip audio post processing
  def apply_post_processing?
    if self.has_default_image?
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
        :square_thumb => "200x200#", 
        :annotation_thumb => "300x200#",
        :medium => "500x500>"
      }
    elsif self.is_pdf?
      {
        :square_thumb => ["200x200#", :png], 
        :annotation_thumb => ["300x200#", :png],
        :medium => ["500x500>", :png]
      }

    elsif self.is_video?
      {
        :square_thumb => { 
          :geometry => "200x200#", 
          :format => 'jpg', 
          :time => 0
        }, 
        :annotation_thumb => {
          :geometry => "300x200#",
          :format => 'jpg',
          :time => 0
        },
        :medium => { 
          :geometry => "500x500>", 
          :format => 'jpg', 
          :time => 0
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
  

  def set_remote_urls
    # save the path to the original file upload, then store the paths to
    # the images we'll use to represent the file
    
    # set the url to the original asset
    if self.file_upload_url != self.file_upload.url(:original)
      self.update_attributes(
        :file_upload_url => self.file_upload.url(:original)
      )
    end

    # then, for each asset type, store a link to the appropriate image assets

    # audio
    if self.is_audio?
      if self.medium_image_url != ActionController::Base.helpers.asset_path("medium_image_url_mp3.png")
        self.update_attributes(
          :medium_image_url => ActionController::Base.helpers.asset_path("medium_image_url_mp3.png")
        )
      end

      if self.annotation_thumb_url != ActionController::Base.helpers.asset_path("annotation_thumb_url_mp3.png")
        self.update_attributes(
          :annotation_thumb_url => ActionController::Base.helpers.asset_path("annotation_thumb_url_mp3.png")
        )
      end

      if self.square_thumb_url != ActionController::Base.helpers.asset_path("square_thumb_url_mp3.png")
        self.update_attributes(
          :square_thumb_url => ActionController::Base.helpers.asset_path("square_thumb_url_mp3.png")
        )
      end

    # plain text
    elsif self.is_plain_text?
      if self.medium_image_url != ActionController::Base.helpers.asset_path("medium_image_url_txt.png")
        self.update_attributes(
          :medium_image_url => ActionController::Base.helpers.asset_path("medium_image_url_txt.png")
        )
      end

      if self.annotation_thumb_url != ActionController::Base.helpers.asset_path("annotation_thumb_url_txt.png")
        self.update_attributes(
          :annotation_thumb_url => ActionController::Base.helpers.asset_path("annotation_thumb_url_txt.png")
        )
      end


      if self.square_thumb_url != ActionController::Base.helpers.asset_path("square_thumb_url_txt.png")
        self.update_attributes(
          :square_thumb_url => ActionController::Base.helpers.asset_path("square_thumb_url_txt.png")
        )
      end


    # word doc
    elsif self.is_word_document?
      if self.medium_image_url != ActionController::Base.helpers.asset_path("medium_image_url_doc.png")
        self.update_attributes(
          :medium_image_url => ActionController::Base.helpers.asset_path("medium_image_url_doc.png")
        )
      end

      if self.annotation_thumb_url != ActionController::Base.helpers.asset_path("annotation_thumb_url_doc.png")
        self.update_attributes(
          :annotation_thumb_url => ActionController::Base.helpers.asset_path("annotation_thumb_url_doc.png")
        )
      end

      if self.square_thumb_url != ActionController::Base.helpers.asset_path("square_thumb_url_doc.png")
        self.update_attributes(
          :square_thumb_url => ActionController::Base.helpers.asset_path("square_thumb_url_doc.png")
        )
      end

    # powerpoint 
    elsif self.is_powerpoint?
      if self.medium_image_url != ActionController::Base.helpers.asset_path("medium_image_url_ppt.png")
        self.update_attributes(
          :medium_image_url => ActionController::Base.helpers.asset_path("medium_image_url_ppt.png")
        )
      end

      if self.annotation_thumb_url != ActionController::Base.helpers.asset_path("annotation_thumb_url_ppt.png")
        self.update_attributes(
          :annotation_thumb_url => ActionController::Base.helpers.asset_path("annotation_thumb_url_ppt.png")
        )
      end

      if self.square_thumb_url != ActionController::Base.helpers.asset_path("square_thumb_url_ppt.png")
        self.update_attributes(
          :square_thumb_url => ActionController::Base.helpers.asset_path("square_thumb_url_ppt.png")
        )
      end

    # excel
    elsif self.is_excel?
      if self.medium_image_url != ActionController::Base.helpers.asset_path("medium_image_url_xls.png")
        self.update_attributes(
          :medium_image_url => ActionController::Base.helpers.asset_path("medium_image_url_xls.png")
        )
      end

      if self.annotation_thumb_url != ActionController::Base.helpers.asset_path("annotation_thumb_url_xls.png")
        self.update_attributes(
          :annotation_thumb_url => ActionController::Base.helpers.asset_path("annotation_thumb_url_xls.png")
        )
      end

      if self.square_thumb_url != ActionController::Base.helpers.asset_path("square_thumb_url_xls.png")
        self.update_attributes(
          :square_thumb_url => ActionController::Base.helpers.asset_path("square_thumb_url_xls.png")
        )
      end

    # other
    else
      record_id_string = self.id.to_s

      # preface the id number with '0' until it's 9 digits long
      while record_id_string.length < 9
        record_id_string = "0" + record_id_string
      end

      # partition the 9 character string into 3 3-digit strings joined by "/"
      id_path = record_id_string.chars.each_slice(3).map(&:join).join("/")

      # use that sequence to identify the full path to the asset
      if self.medium_image_url != self.file_upload.url(:medium).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 
        self.update_attributes(
          :medium_image_url => self.file_upload.url(:medium).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 
        )
      end

      if self.annotation_thumb_url != self.file_upload.url(:annotation_thumb).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 
        self.update_attributes(
          :annotation_thumb_url => self.file_upload.url(:annotation_thumb).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 
        )
      end

      if self.square_thumb_url != self.file_upload.url(:square_thumb).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 
        self.update_attributes(
          :square_thumb_url => self.file_upload.url(:square_thumb).gsub(/file_uploads\/\//, 'file_uploads/' + id_path + "/") 
        )
      end

    end
  end


  def set_media_type
    # set a simple field {img, audio, video} that tells the ui
    # what kind of div should contain this attachment
    if self.is_audio?
      if self.media_type != "audio"
        self.update_attributes(
          :media_type => "audio"
        )
      end
    elsif self.is_video?
      if self.media_type != "video"
        self.update_attributes(
          :media_type => "video"
        )
      end
    else
      if self.media_type != "image"
        self.update_attributes(
          :media_type => "image"
        )
      end
    end
  end


end