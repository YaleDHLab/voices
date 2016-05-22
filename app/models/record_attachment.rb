class RecordAttachment < ActiveRecord::Base
  print "record attachment", self

  belongs_to :record, touch: true

  # Before saving the record to the database, manually add a new
  # field to the record that exposes the url where the file is uploaded
  after_save :set_remote_urls, :set_media_type


  # Helper method that uses the =~ regex method to see if 
  # the current file_upload has a content_type 
  # attribute that contains the string "image" / "video", or "audio"
  def is_image?
    self.mimetype =~ %r(image)
  end

  def is_video?
    self.mimetype =~ %r(video)
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
      if self.placeholder_image_path!= ActionController::Base.helpers.asset_path("ppt.png")
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
      if self.placeholder_image_path!= ActionController::Base.helpers.asset_path("svg.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("svg.png")
        )
      end

    # pdf
    elsif self.is_pdf?
      if self.placeholder_image_path!= ActionController::Base.helpers.asset_path("pdf.png")
        self.update_attributes(
          :placeholder_image_path => ActionController::Base.helpers.asset_path("pdf.png")
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