class AddTranscodedVideoUrlToRecordAttachmentAttributes < ActiveRecord::Migration
  def change
    add_column :record_attachments, :transcoded_video_url, :text
  end
end
