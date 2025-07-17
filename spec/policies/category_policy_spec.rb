require 'rails_helper'

RSpec.describe CategoryPolicy do
  subject { described_class }

  let(:user) do
    FactoryBot.create(:user, full_name: 'Regular User', email: 'user@example.com', password: 'password123',
                             role: 'buyer')
  end
  let(:admin) do
    FactoryBot.create(:user, full_name: 'Admin User', email: 'admin@example.com', password: 'password123',
                             role: 'admin')
  end
  let(:category) { FactoryBot.create(:category, name: 'Sample Category') }

  permissions :index?, :show? do
    it 'grants access to any user' do
      expect(subject).to permit(user, category)
      expect(subject).to permit(admin, category)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies access to regular users' do
      expect(subject).not_to permit(user, category)
    end

    it 'grants access to admins' do
      expect(subject).to permit(admin, category)
    end
  end
end
