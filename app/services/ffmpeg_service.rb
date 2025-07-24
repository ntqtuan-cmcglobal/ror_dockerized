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
end
