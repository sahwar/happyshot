class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!, only: [:create, :my_posts]
  before_action :user_authentication, only: [:create, :my_posts]
  before_action :verify_is_admin, only: [:new]
  # GET /posts
  # GET /posts.json
  def index
    # http://www.sitepoint.com/infinite-scrolling-rails-basics/
    # @posts = Post.all.order('created_at DESC')
    @posts = Post.where(:publish=>true).order('created_at DESC').page(params[:page])
    @post = Post.new
    @favorite = Favorite.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    # @post = Post.new(post_params)
    @post = current_user.posts.create(post_params)

    # File.open("public/videos", "rb") do | file |
    #   @post.video = file
    #   # file.write(@post.video)
    # end
    # StringIO.open(Base64.decode64(@post.image)) do |data|
    #   data.class.class_eval { attr_accessor :original_filename, :content_type }
    #   data.original_filename = "file.gif"
    #   data.content_type = "image/gif"
    #   self.image = data
    # end

    # image = Magick::ImageList.new
    # File.open('public/test.gif', 'wb') do|f|
    #   gif = image.from_blob(Base64.decode64(@post.image))
    #   # gif = Base64.decode64(@post.image).force_encoding('UTF-8').encode
    #   f.write(gif)
    # end
    # @post.image = "test.gif"
    # @post.publish=true
    # @post.user = current_user
    # @post.save!
    redirect_to :action => :index
    
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def my_posts
    @posts = Post.where(:user_id=>current_user.id).order('created_at DESC').page(1)
    @post = Post.new
    @favorite = Favorite.new
    render :index
  end

  def add_new_comment
    @post = Post.find(params[:id])
    comment = @post.comments.create
    comment.user = current_user
    comment.comment = params[:comment]
    comment.save
    # updates the model to invalidate the previous cach
    @post.touch
    # redirect_to :action => :index
    respond_to do |format|
      format.html{render :index}
      format.js
    end
  end

  def dis_or_like
    @post = Post.find(params[:id])
    if @post.favorites.where(:user_id=>current_user.id).count > 0
      @post.favorites.where(:user_id=>current_user.id)[0].delete
    else
      current_user.favorites.create(:post_id => params[:id])
    end
    # updates the model to invalidate the previous cach
    @post.touch
    respond_to do |format|
      format.html{render :index}
      format.js
    end
  end

  def report_post
    puts "post reported"
    @post = Post.find(params[:id])
    # block the post if admin reports
    if current_user.admin?
      @post.publish = false
      @post.save!
      redirect_to :action => :index
      # prevent user if s/he tries to repot twice
    elsif @post.reports.group_by(&:user_id).include? current_user.id
      redirect_to :action => :index
    else
      @report = Report.new
      @report.user_id = current_user.id
      @report.post_id = @post.id
      @report.type = params[:type].to_i
      @report.save

      if @post.reports.count > 0
        nodality = 0
        graphic = 0
        others = 0
        @post.reports.each do |r|
          if r.nodality?
            nodality+=1
          elsif r.graphic?
            graphic+=1
          else
            others+=1
          end
        end

        if nodality > 0 || graphic > 2
          @post.publish = false
          @post.save!
        end

      end
      # updates the model to invalidate the previous cach
      @post.touch
      redirect_to :action => :index
    end

  end



  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:user_id,:note,:tags,:image,:comment,:publish, :interval, :video)
  end
end

def verify_is_admin
  (current_user.nil?) ? redirect_to(root_path) : (redirect_to(root_path) unless current_user.admin?)
end

def user_authentication
  if current_user.nil?
    session[:post_params] = post_params
    redirect_to(user_session_path)
  end
end
