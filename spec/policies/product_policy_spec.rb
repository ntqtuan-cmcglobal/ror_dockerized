# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductPolicy do
  subject { described_class }

  let(:user) do
    FactoryBot.create(:user, full_name: 'Regular User', email: 'user@example.com', password: 'password123',
                             role: 'buyer')
  end
  let(:admin) do
    FactoryBot.create(:user, full_name: 'Admin User', email: 'admin@example.com', password: 'password123',
                             role: 'admin')
  end
  let(:product) { FactoryBot.create(:product, name: 'Sample Product', price: 9.99, user: admin) }

  permissions :index?, :show? do
    it 'grants access to any user' do
      expect(subject).to permit(user, product)
      expect(subject).to permit(admin, product)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'denies access to regular users' do
      expect(subject).not_to permit(user, product)
    end

    it 'grants access to admins' do
      expect(subject).to permit(admin, product)
    end
  end
end
