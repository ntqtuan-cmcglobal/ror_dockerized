require 'rails_helper'

RSpec.describe ImportCsvFileProductsJob, type: :job do
  let(:import_file) { instance_double(ImportFile, id: 1) }
  let(:user) { instance_double(User, id: 2) }
  let(:csv_service) { instance_double(CsvService) }

  before do
    allow(ImportFile).to receive(:find).with(import_file.id).and_return(import_file)
    allow(User).to receive(:find).with(user.id).and_return(user)
    allow(CsvService).to receive(:new).and_return(csv_service)
    allow(csv_service).to receive(:import_file)
  end

  it 'calls CsvService#import_file with correct arguments' do
    described_class.new.perform(import_file.id, user.id)
    expect(csv_service).to have_received(:import_file).with('Product', import_file, user)
  end
end
