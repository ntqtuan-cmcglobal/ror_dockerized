require 'streamio-ffmpeg'

class FfmpegService
  def self.generate_thumbnail(video)
    tempfile = Tempfile.new(['thumbnail', '.jpg'])
    video.open do |file|
      movie = FFMPEG::Movie.new(file.path)
      movie.screenshot(tempfile.path, seek_time: 2, resolution: '320x240')
    end

    tempfile
  end

  # Reduce quality for video, image, or audio file
  # type: :video, :image, :audio
  # options: hash of quality params
  def self.generate_demo(digital_asset)
    tempfile = Tempfile.new(['demo', File.extname(digital_asset.filename.to_s)])
    digital_asset.open do |file|
      movie = FFMPEG::Movie.new(file.path)
      case digital_asset.content_type
      when 'video/mp4'
        movie.transcode(tempfile.path, %w[-b:v 500k -s 640x360 -b:a 64k])
      when 'image/jpeg'
        system("ffmpeg -y -i #{Shellwords.escape(file.path)} -q:v 30 #{Shellwords.escape(tempfile.path)}")
      when 'audio/mpeg'
        system("ffmpeg -y -i #{Shellwords.escape(file.path)} -b:a 64k #{Shellwords.escape(tempfile.path)}")
      else
        raise ArgumentError, "Unsupported content type: #{digital_asset.content_type}"
      end
    end

    tempfile
  end
end
