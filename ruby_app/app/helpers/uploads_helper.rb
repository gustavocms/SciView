module UploadsHelper
  def s3_direct_post
    @s3_direct_post ||= S3_BUCKET.presigned_post(
      key: s3_post_key,
      success_action_status: 201,
      acl: :private
    )
  end

  def s3_post_url
    s3_direct_post.url.to_s
  end

  def s3_host
    s3_direct_post.url.host
  end

  private

  def s3_post_key
    "uploads/#{SecureRandom.uuid}/${filename}"
  end
end
