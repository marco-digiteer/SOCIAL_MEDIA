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

    else
      @posts = Post.where(visibility: true).order(created_at: :desc)  # Add pagination for non-admins
    end

    puts "Post Count: #{@posts.count}"
    @pagy, @posts = pagy(@posts, items: 6, limit: 6)

    puts "Pagy: #{@pagy.inspect}"
  end
end
