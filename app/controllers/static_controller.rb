class StaticController < ApplicationController

  skip_before_action :authenticate_user!, :authenticate_user_from_token!

  def about; end

  def privacy; end

  def home
    @hide_search_box = true
    @resources = []
    [Event, Material].each do |resource|
      @resources += resource.search_and_filter(nil, '', { 'max_age' => '1 month' }, sort_by: 'new', per_page: 5).results
    end
  end
end
