Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'

# see SO thread 9646549 for a discussion of this method
# config/initializers/paperclip.rb
Paperclip.interpolates(:placeholder) do |attachment, style|
  ActionController::Base.helpers.asset_path("missing_#{style}.png")
end

# add initializer that manually overrides 3gpp mimetype to audio
android_audio_type = MIME::Types["audio/3gpp"].first
android_audio_type.extensions << "3gpp"
MIME::Types.index_extensions android_audio_type