module ContentItemHelper
  def content_item_preview_url(item)
    return nil unless item
    if item.respond_to?(:file) && item.file.attached?
      return url_for(item.file)
    end
    raw = item.respond_to?(:url) ? item.url : nil
    raw.present? ? url_with_scheme(raw) : nil
  end

  def render_content_item(item)
    case item.kind
    when 'image', 'gif'
      render_image_content(item)
    when 'video'
      render_video_content(item)
    when 'audio'
      render_audio_content(item)
    when 'link'
      render_link_content(item)
    else
      content_tag(:p, item.kind.upcase)
    end
  end

  private

  def url_with_scheme(url)
    return url if url.to_s.match?(%r{\A[a-z][a-z0-9+.-]*://}i)
    "https://#{url.to_s.sub(/\A\/+/, '')}"
  end

  def render_image_content(item)
    if item.file.attached?
      return image_tag(item.file, alt: item.title)
    end
    return unless item.url
    image_tag(item.url, alt: item.title)
  end

  def render_video_content(item)
    if item.file.attached?
      return video_tag(item.file, controls: true)
    end
    return unless item.url
    video_tag(item.url, controls: true)
  end

  def render_audio_content(item)
    if item.file.attached?
      return audio_tag(item.file, controls: true)
    end
    return unless item.url
    audio_tag(item.url, controls: true)
  end

  def render_link_content(item)
    return unless item.url
    
    link_to(
      item.title,
      item.url,
      target: '_blank',
      rel: 'noopener'
    )
  end
end
