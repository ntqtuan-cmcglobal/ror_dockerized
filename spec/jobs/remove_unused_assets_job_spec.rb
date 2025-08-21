require 'rails_helper'

RSpec.describe RemoveUnusedAssetsJob, type: :job do
  let(:blob) { instance_double(ActiveStorage::Blob) }

  before do
    allow(ActiveStorage::Blob).to receive_message_chain(:unattached, :find_each).and_yield(blob)
    allow(blob).to receive(:purge_later)
  end

  it 'purges unattached blobs' do
    expect(blob).to receive(:purge_later)
    described_class.perform_now
  end
end
