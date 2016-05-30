class ReaddPathsToMediumImageAnnotationThumbAndSquareThumb < ActiveRecord::Migration
  def change
    add_column :record_attachments, :medium_image_url, :text
    add_column :record_attachments, :annotation_thumb_url, :text
    add_column :record_attachments, :square_thumb_url, :text
  end
end
