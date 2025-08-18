class ImportFilePolicy
  attr_reader :user, :import_file

  def initialize(user, import_file)
    @user = user
    @import_file = import_file
  end

  def bulk_import?
    user.present? && (user.admin? || user.seller?)
  end
end
