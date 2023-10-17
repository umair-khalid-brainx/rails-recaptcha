class PostsController < ApplicationController
  def index
    @posts = Post.all
    @post = Post.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    # if verify_recaptcha(model: @post) && @post.save
    #   redirect_to posts_path, notice: 'Post was successfully created.'
    # else
    #   render :index, status: :unprocessable_entity
    # end
    # debugger
    success = verify_recaptcha(action: 'create_post', minimum_score: 1)
    checkbox_success = verify_recaptcha(model: @post, site_key: Rails.application.credentials.recaptcha_v2.site_key) unless success
    if success || checkbox_success
      @post.save
      redirect_to posts_path, notice: 'Post was successfully created.'
    else
      if !success
        @show_checkbox_recaptcha = true
        Rails.logger.warn("Post not saved because of a recaptcha score of #{recaptcha_reply['score']}")
      end
      render :index, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
