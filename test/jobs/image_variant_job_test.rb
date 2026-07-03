require "test_helper"

class ImageVariantJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "essay cover attach enqueues variant warming for the blob" do
    assert_enqueued_with(job: ImageVariantJob) { attach_image essays(:draft).cover }
  end

  test "field series cover attach enqueues variant warming" do
    assert_enqueued_with(job: ImageVariantJob) { attach_image field_series(:iceland).cover }
  end

  test "field item photo attach enqueues watermarking and EXIF extraction" do
    item = field_items(:photo_one)

    assert_enqueued_with(job: ImageVariantJob, args: [ item, { watermark: true } ]) do
      assert_enqueued_with(job: ExtractExifJob, args: [ item ]) do
        attach_image item.photo
      end
    end
  end

  test "rich text image embed enqueues variant warming for the blob" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("test/fixtures/files/test_image.jpg")),
      filename: "embed.jpg", content_type: "image/jpeg"
    )

    assert_enqueued_with(job: ImageVariantJob, args: [ blob ]) do
      essays(:draft).update!(content: ActionText::Content.new("").append_attachables(blob))
    end
  end

  test "watermarked photo attach does not re-enqueue the pipeline" do
    assert_no_enqueued_jobs(only: [ ImageVariantJob, ExtractExifJob ]) do
      attach_image field_items(:photo_one).watermarked_photo
    end
  end

  private
    def attach_image(attachment)
      attachment.attach io: File.open(Rails.root.join("test/fixtures/files/test_image.jpg")),
                        filename: "test.jpg", content_type: "image/jpeg"
    end
end
