require 'rails_helper'

RSpec.describe VideoThumbnailGenerateJob, type: :job do
  let(:product) { instance_double(Product, id: 1, digital_asset: digital_asset, error_message: nil) }
  let(:digital_asset) { instance_double('DigitalAsset', attached?: true, content_type: 'video/mp4') }

  before do
    allow(Product).to receive(:find).with(product.id).and_return(product)
    allow(product).to receive(:digital_asset).and_return(digital_asset)
    allow(product).to receive(:generate_video_thumbnail)
    allow(product).to receive(:save)
    allow(product).to receive(:error_message).and_return(nil)
    allow(product).to receive(:error_message=)
  end

  context 'when product has a video digital asset attached' do
    it 'calls generate_video_thumbnail' do
      expect(product).to receive(:generate_video_thumbnail)
      described_class.new.perform(product.id)
    end

    it 'clears error_message before generating thumbnail if present' do
      allow(product).to receive(:error_message).and_return('Some error')
      expect(product).to receive(:error_message=).with(nil)
      expect(product).to receive(:save)
      described_class.new.perform(product.id)
    end
  end

  context 'when product does not have a digital asset attached' do
    before { allow(digital_asset).to receive(:attached?).and_return(false) }

    it 'does not call generate_video_thumbnail' do
      expect(product).not_to receive(:generate_video_thumbnail)
      described_class.new.perform(product.id)
    end
  end

  context 'when product digital asset is not a video' do
    before { allow(digital_asset).to receive(:content_type).and_return('image/png') }

    it 'does not call generate_video_thumbnail' do
      expect(product).not_to receive(:generate_video_thumbnail)
      described_class.new.perform(product.id)
    end
  end

  context 'when an error occurs during thumbnail generation' do
    before do
      allow(product).to receive(:generate_video_thumbnail).and_raise(StandardError.new('Thumbnail error'))
    end

    it 'sets error_message on product' do
      expect(product).to receive(:error_message=).with('Thumbnail error')
      expect(product).to receive(:save)
      described_class.new.perform(product.id)
    end
  end
end
