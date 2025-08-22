require 'rails_helper'

describe FfmpegService do
  let(:video_file) { fixture_file_upload(Rails.root.join('test/fixtures/files/sample.mp4'), 'video/mp4') }
  let(:image_file) { fixture_file_upload(Rails.root.join('test/fixtures/files/sample.jpg'), 'image/jpeg') }
  let(:audio_file) { fixture_file_upload(Rails.root.join('test/fixtures/files/sample.mp3'), 'audio/mpeg') }
  let(:text_file) { fixture_file_upload(Rails.root.join('test/fixtures/files/sample.txt'), 'text/plain') }

  describe '.generate_thumbnail' do
    it 'returns a Tempfile for a video' do
      allow(FFMPEG::Movie).to receive(:new).and_return(double('movie', screenshot: true))
      tempfile = FfmpegService.generate_thumbnail(video_file)
      expect(tempfile).to be_a(Tempfile)
      expect(File.exist?(tempfile.path)).to be true
    end
  end

  describe '.generate_demo' do
    it 'returns a Tempfile for a video with watermark' do
      allow(FFMPEG::Movie).to receive(:new).and_return(double('movie', transcode: true))
      tempfile = FfmpegService.generate_demo(video_file)
      expect(tempfile).to be_a(Tempfile)
      expect(File.exist?(tempfile.path)).to be true
    end

    it 'returns a Tempfile for an image with watermark' do
      allow_any_instance_of(Object).to receive(:system).and_return(true)
      tempfile = FfmpegService.generate_demo(image_file)
      expect(tempfile).to be_a(Tempfile)
      expect(File.exist?(tempfile.path)).to be true
    end

    it 'returns a Tempfile for an audio file with reduced quality' do
      allow_any_instance_of(Object).to receive(:system).and_return(true)
      tempfile = FfmpegService.generate_demo(audio_file)
      expect(tempfile).to be_a(Tempfile)
      expect(File.exist?(tempfile.path)).to be true
    end

    # it 'raises error for unsupported type' do
    #   expect { FfmpegService.generate_demo(text_file) }.to raise_error(ArgumentError)
    # end
  end
end
