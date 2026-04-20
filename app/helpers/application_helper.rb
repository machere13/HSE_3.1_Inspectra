module ApplicationHelper
  include Pagy::Frontend

  def page_meta_scope
    "#{controller_path.tr('/', '.')}.#{action_name}"
  end

  def page_meta_title
    return content_for(:meta_title).strip if content_for?(:meta_title)

    t("#{page_meta_scope}.title", default: t('layouts.application.title'))
  end

  def page_meta_description
    return content_for(:meta_description).strip if content_for?(:meta_description)

    t("#{page_meta_scope}.description", default: t('layouts.application.description', default: page_meta_title))
  end

  def page_og_image
    return content_for(:og_image).strip if content_for?(:og_image)

    image_url('opengraphs/og_default.png')
  end

  def render_markdown(text)
    source = text.to_s
    return '' if source.blank?

    html =
      if defined?(Commonmarker)
        Commonmarker.to_html(source, options: { extension: { table: true, strikethrough: true, autolink: true } })
      else
        simple_format(ERB::Util.html_escape(source))
      end

    sanitize(
      html,
      tags: %w[p br h1 h2 h3 h4 h5 h6 ul ol li blockquote pre code hr a strong em del table thead tbody tr th td img],
      attributes: %w[href src alt title target rel]
    )
  end

  def generate_interactive_content
    paragraphs = []
    
    begin
      require 'faker'
      Faker::Config.locale = :en
      _prev_enforce = I18n.enforce_available_locales
      I18n.enforce_available_locales = false
      
      3.times do
        paragraphs << Faker::Lorem.paragraph(sentence_count: rand(4..8))
      end
      
      I18n.enforce_available_locales = _prev_enforce if _prev_enforce
    rescue => e
      Rails.logger.warn "Faker not available, using fallback content: #{e.message}"
      paragraphs = [
        'Like many of his superhuman brethren, these sources say that the young primarch thrived in Cthonia\'s harsh environment, learning his first lessons in war and killing from Cthonia\'s tech-barbarian kill-gangs. The world of Cthonia had been settled in the very earliest days of Humanity\'s exploration of the stars, its rich natural resources ruthlessly exploited until they were all but played out.',
        'Thus, Horus grew to maturity amongst the anarchic gangers that populated the post-industrial nightmare of a world honeycombed with long-extinct mines and dominated by decaying hive cities. Though Horus had not been raised during his formative years on Cthonia -- uncommonly, for a primarch, he had not matured on the cradle-world of his Legion -- he spoke the harsh language known as Cthonic fluently.',
        'In fact, he spoke it with the particular hard palatal edge and rough vowels of a Western Hemispheric ganger, the commonest and roughest of Cthonia\'s feral castes. The world had been stripped of its resources, leaving behind only the remnants of a once-great civilization, now reduced to gangs and scavengers.'
      ]
    end
    
    {
      paragraphs: paragraphs,
      image_url: 'https://i.pinimg.com/1200x/ae/9a/a9/ae9aa9ac9a2f6cc5aab13940e71cac03.jpg'
    }
  end
end

