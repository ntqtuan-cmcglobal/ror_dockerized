# frozen_string_literal: true

# Policy class for User authorization.
class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def show?
    user.admin? || user == record
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || user == record
  end

  # Alias for update? to support edit? checks
  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  # Scope class for resolving user records.
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    class Scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        if user.admin?
          scope.all
        else
          scope.where(id: user.id)
        end
      end

      private

      attr_reader :user, :scope
    end
  end
end
