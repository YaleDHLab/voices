class RecordAttachment < ActiveRecord::Base
  print "record attachment", self

  belongs_to :record, touch: true

  # Before saving the record to the database, manually add a new
  # field to the record that exposes the url where the file is uploaded
  after_save :set_remote_urls, :set_media_type

  # Angular will handle client side file uploads of image assets, but
  # we need a server side upload option for multimedia assets to standardize
  # encodings of video and audio files; use paperclip for this purpose
  # Use the has_attached_file method to add a file_upload property to the Record
  # class. 
  has_attached_file :file_upload,
    # In order to determine the styles of the image we want to save
    # e.g. a small style copy of the image, plus a large style copy
    # of the image, call the check_file_type method
    styles: lambda { |a| a.instance.check_file_type },

    processors: lambda { 
      |a| a.is_video? ? [ :ffmpeg ] : [ :thumbnail ] 
    },

    # upload files to https
    :s3_protocol => :https,

    # Skip Paperclip's validations, as Angular will validate all uploads before upload
    validate_media_type: false

  # Indicate we don't want to run validations server side (as client handles this)
  do_not_validate_attachment_file_type :file_upload

  # Before applying the Imagemagick post processing to this record
  # check to see if we indeed wish to process the file. In the case
  # of audio files, we don't want to apply post processing
  before_post_process :apply_post_processing?

  # Method to determine whether we need to apply post processing on the file
  # Audio files should not be sent through post processing
  def apply_post_processing?
    if self.is_video?
      return true
    elsif self.is_seed && self.is_image?
      return true  
    else 
      return false 
    end
  end

  # Method to be called in order to determine what styles we should
  # save of a file.
  def check_file_type
    if self.is_pdf?
      {
        :square_thumb => ["200x200#", :png], 
        :annotation_thumb => ["300x200#", :png],
        :medium => ["500x500>", :png]
      }

    elsif self.is_video?
      {
        :square_thumb => { 
          :geometry => "200x200!", 
          :format => 'jpg', 
          :time => 1
        }, 
        :annotation_thumb => {
          :geometry => "300x200!",
          :format => 'jpg',
          :time => 1
        },
        :medium => { 
          :geometry => "500x500>", 
          :format => 'jpg', 
          :time => 1
        },
        :transcoded_video => {
          :geometry => "300x200!", 
          :format => 'mp4'
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


  # Helper method that uses the =~ regex method to see if 
  # the current file_upload has a content_type 
  # attribute that contains the string "image" / "video", or "audio"
  # Attachments sent from the client will have mimetype; those from the
  # server will have file_upload_content_type
  def is_image?
    if self.mimetype
      self.mimetype =~ %r(image)
    elsif self.file_upload_content_type
      self.file_upload_content_type =~ %r(image)
    end
  end

  def is_video?
    if self.mimetype
      self.mimetype =~ %r(video)
    elsif self.file_upload_content_type
      self.file_upload_content_type =~ %r(video)
    end
  end

  def is_audio?
    self.mimetype =~ /\Aaudio\/.*\Z/
  end

  def is_plain_text?
    self.filename =~ %r{\.(txt)$}i
  end

  def is_excel?
    self.filename =~ %r{\.(xls|xlt|xla|xlsx|xlsm|xltx|xltm|xlsb|xlam|csv|tsv)$}i
  end

  def is_word_document?
    self.filename =~ %r{\.(docx|doc|dotx|docm|dotm)$}i
  end

  def is_powerpoint?
    self.filename =~ %r{\.(pptx|ppt|potx|pot|ppsx|pps|pptm|potm|ppsm|ppam)$}i
  end

  def is_pdf?
    self.filename =~ %r{\.(pdf)$}i
  end

  def is_svg?
    self.filename =~ %r{\.(svg)$}i
  end

  def has_default_image?
    is_audio?
    is_plain_text?
    is_excel?
    is_word_document?
    is_powerpoint?
    is_svg?
    is_pdf?
  end
  

  def set_remote_urls
    # save the path to the original file upload, then store the paths to
    # the images we'll use to represent the file

    # store a link to the appropriate placeholder image path (if relevant)

    # audio
    if self.is_audio?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("mp3.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("mp3.png")
        )
      end

    # plain text
    elsif self.is_plain_text?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("txt.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("txt.png")
        )
      end

    # word doc
    elsif self.is_word_document?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("doc.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("doc.png")
        )
      end

    # powerpoint 
    elsif self.is_powerpoint?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("ppt.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("ppt.png")
        )
      end

    # excel
    elsif self.is_excel?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("xls.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("xls.png")
        )
      end

    # svg
    elsif self.is_svg?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("svg.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("svg.png")
        )
      end

    # pdf
    elsif self.is_pdf?
      if self.placeholder_image_path != ActionController::Base.helpers.asset_path("pdf.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("pdf.png")
        )
      end


    # video
    elsif self.is_video?

      # Update the following paths for video files: 
      #   file_upload_url
      #   transcoded_video_url
      #   medium_image_url
      #   annotation_thumb_url
      #   square_thumb_url

      ###################
      # file upload url #
      ###################

      if self.file_upload_url != self.file_upload.url(:original)
        self.update_attributes(
          :file_upload_url => self.file_upload.url(:original),
          :transcoded_video_url => self.file_upload.url(:transcoded_video),
          :medium_image_url => self.file_upload.url(:medium),
          :annotation_thumb_url => self.file_upload.url(:annotation_thumb),
          :square_thumb_url => self.file_upload.url(:square_thumb)
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