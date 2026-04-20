class WeekOgImageService
  WIDTH = 1200
  HEIGHT = 630
  PATTERN_OPACITY = 1

  def self.call!(week)
    new(week).call!
  end

  def initialize(week)
    @week = week
  end

  def call!
    png = build_png
    @week.og_image.attach(
      io: StringIO.new(png),
      filename: "week-#{@week.number}-og.png",
      content_type: 'image/png'
    )
  end

  private

  def build_png
    require 'mini_magick'
    require 'open-uri'
    require 'tempfile'

    base_path = fetch_base_image_path
    pattern_path = Rails.root.join('app/assets/images/opengraphs/og.png').to_s

    base = MiniMagick::Image.open(base_path)
    base.combine_options do |c|
      c.resize "#{WIDTH}x#{HEIGHT}^"
      c.gravity 'Center'
      c.extent "#{WIDTH}x#{HEIGHT}"
    end

    if File.exist?(pattern_path)
      pattern = MiniMagick::Image.open(pattern_path)
      pattern.combine_options do |c|
        c.resize "#{WIDTH}x#{HEIGHT}^"
        c.gravity 'Center'
        c.extent "#{WIDTH}x#{HEIGHT}"
      end

      base = base.composite(pattern) do |c|
        c.compose 'Over'
        c.dissolve "#{(PATTERN_OPACITY * 100).to_i}x100"
        c.gravity 'Center'
      end
    end

    base.combine_options do |c|
      c.fill '#FFFFFF'
      c.font 'Arial-Bold'
      c.pointsize '96'
      c.gravity 'North'
      c.annotate '+0+64', "Week #{@week.number}"
    end

    base.format('png')
    base.to_blob
  end

  def fetch_base_image_path
    item = @week.content_items
      .where(kind: %w[image gif])
      .order(Arel.sql('position NULLS LAST'), :id)
      .first

    return default_background_path unless item

    if item.file.attached?
      tmp = Tempfile.new(["week-#{@week.number}-base", File.extname(item.file.filename.to_s)])
      tmp.binmode
      tmp.write(item.file.download)
      tmp.close
      tmp.path
    elsif item.url.present?
      tmp = Tempfile.new(["week-#{@week.number}-base", File.extname(URI.parse(item.url).path.presence || '.img')])
      tmp.binmode
      tmp.write(URI.parse(item.url).open.read)
      tmp.close
      tmp.path
    else
      default_background_path
    end
  rescue StandardError
    default_background_path
  end

  def default_background_path
    tmp = Tempfile.new(['og-bg', '.png'])
    tmp.binmode
    img = MiniMagick::Image.create('png') { |f| f.write '' }
    img.combine_options do |c|
      c.size "#{WIDTH}x#{HEIGHT}"
      c.canvas 'rgb(7,7,7)'
    end
    img.write(tmp.path)
    tmp.close
    tmp.path
  end
end
