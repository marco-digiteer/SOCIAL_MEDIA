class PostsController < ApplicationController
  include Pagy::Backend
  
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :my_posts]
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    if admin_signed_in?
      @pagy, @posts = pagy(Post.all)
    else
      @pagy, @posts = pagy(Post.where(visibility: true).order(created_at: :desc))
    end
  end

  def featured
    @pagy, @posts = pagy(Post.where(featured: true, visibility: true).order(created_at: :desc))
  end

  def my_posts
    @pagy, @posts = pagy(Post.where(email: current_user.email).order(created_at: :desc))
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.email = current_user.email
    @post.featured = false
    @post.visibility = true
  
    if @post.save
      redirect_to root_path, notice: "Post created successfully."
    else
      render :new
    end
  end
  
  def update
    if @post.update(post_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("post_#{@post.id}", partial: "posts/user_post", locals: { post: @post }) }
        format.html { redirect_to posts_path, notice: "Post updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render partial: "posts/inline_form", locals: { post: @post } }
        format.html { render :edit }
      end
    end
  end
  
  def edit_inline
    @post = Post.find(params[:id])
    render partial: "posts/inline_form", locals: { post: @post }
  end
  
  def destroy
    @post.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to posts_path, notice: "Post deleted successfully." }
    end
  end

  def show
    @post = Post.find(params[:id])
    render partial: "posts/user_post", locals: { post: @post }
  end
  
  
  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to posts_path, alert: "Not authorized." unless @post.email == current_user.email
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
