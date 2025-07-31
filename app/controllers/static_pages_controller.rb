class StaticPagesController < ApplicationController

  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
    # => app/views/リソース名/アクション名.html.erb
    # => app/views/static_pages/home.html.erb
  end

  def help
  end

  def about
  end

  def contact
  end
end
