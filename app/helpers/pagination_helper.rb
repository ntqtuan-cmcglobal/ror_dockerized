# app/helpers/pagination_helper.rb
module PaginationHelper
  def current_per_page_for(collection)
    pp "collection #{collection}"
    collection.try(:limit_value) || collection.try(:class).try(:default_per_page) || 12
  end
end
