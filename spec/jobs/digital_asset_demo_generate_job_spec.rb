require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DigitalAssetDemoGenerateJob, type: :job do
  let(:product) do
    instance_double(Product, id: 1, error_message: nil, digital_asset: double('Attachment', attached?: true))
  end

  before do
    allow(Product).to receive(:find).with(product.id).and_return(product)
    allow(product).to receive(:save)
    allow(product).to receive(:generate_digital_asset_demo)
    allow(product.digital_asset).to receive(:attached?).and_return(true)
  end

  describe 'queueing' do
    it 'enqueues the job in the correct queue' do
      expect do
        described_class.perform_async(product.id)
      end.to change(described_class.jobs, :size).by(1)
      expect(described_class.jobs.last['queue']).to eq('digital_asset_demo_generate')
    end
  end

  describe '#perform' do
    it 'clears error message and generates demo if digital asset is attached' do
      allow(product).to receive(:error_message).and_return('some error')
      expect(product).to receive(:error_message=).with(nil)
      expect(product).to receive(:save).at_least(:once)
      expect(product).to receive(:generate_digital_asset_demo)
      described_class.new.perform(product.id)
    end

    it 'sets error_message if an exception occurs' do
      allow(product).to receive(:generate_digital_asset_demo).and_raise(StandardError.new('fail'))
      expect(product).to receive(:error_message=).with('fail')
      expect(product).to receive(:save).at_least(:once)
      described_class.new.perform(product.id)
    end
  end
end
