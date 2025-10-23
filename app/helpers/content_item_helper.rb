module ContentItemHelper
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

  def render_image_content(item)
    return unless item.url
    
    image_tag(
      item.url,
      alt: item.title,
    )
  end

  def render_video_content(item)
    return unless item.url
    
    video_tag(
      item.url,
      controls: true,
    )
  end

  def render_audio_content(item)
    return unless item.url
    
    audio_tag(
      item.url,
      controls: true,
    )
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
