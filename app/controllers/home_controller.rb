class HomeController < ApplicationController
  include Pagy::Backend

  def index
    if admin_signed_in?
      sort_param = params[:sort] || "newest"
      user_filter = params[:user]
  
      @posts = Post.all
      @posts = @posts.where(email: user_filter) if user_filter.present?
  
      @posts = case sort_param
               when "oldest"
                 @posts.order(created_at: :asc)
               when "title_asc"
                 @posts.order(title: :asc)
               when "title_desc"
                 @posts.order(title: :desc)
               else
                 @posts.order(created_at: :desc)
               end

      @users = Post.select(:email).distinct.pluck(:email)

      # Paginate the posts for admins
      @pagy, @posts = pagy(@posts)
    else
      @pagy, @posts = pagy(Post.all.order(created_at: :desc))  # Add pagination for non-admins
    end
  end
end
