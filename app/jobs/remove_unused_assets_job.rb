class RemoveUnusedAssetsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # Remove unused assets
    # Find and delete unused assets from the storage
    # This job can be scheduled to run periodically
    ActiveStorage::Blob.unattached.find_each do |blob|
      blob.purge_later
    end
  end
end
