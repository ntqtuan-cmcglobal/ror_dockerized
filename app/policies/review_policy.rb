class ReviewPolicy
  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    @review = review
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present? && user.buyer?
  end

  def update?
    user.present? && user.buyer? && (review.user_id == user.id)
  end

  def destroy?
    user.present? && (review.user_id == user.id || user.admin?)
  end

  def save_review?
    create? || update?
  end

  def delete_review?
    destroy?
  end
end
