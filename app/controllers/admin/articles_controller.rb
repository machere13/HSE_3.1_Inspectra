class Admin::ArticlesController < Admin::BaseController
  before_action :set_week
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @articles = pagy(@week.articles.order(:created_at), items: 20)
    authorize! :read, Article
  end

  def show
    authorize! :read, @article
  end

  def new
    @article = @week.articles.new
    authorize! :create, @article
  end

  def create
    @article = @week.articles.new(article_params)
    authorize! :create, @article
    @article.cover_image.purge if params.dig(:article, :remove_cover_image) == '1'
    if @article.save
      redirect_to admin_week_article_path(@week, @article), notice: 'Статья создана'
    else
      flash.now[:alert] = @article.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! :update, @article
  end

  def update
    authorize! :update, @article
    @article.cover_image.purge if params.dig(:article, :remove_cover_image) == '1'
    if @article.update(article_params)
      redirect_to admin_week_article_path(@week, @article), notice: 'Статья обновлена'
    else
      flash.now[:alert] = @article.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @article
    @article.destroy
    redirect_to admin_week_articles_path(@week), notice: 'Статья удалена'
  end

  private

  def set_week
    @week = Week.find_by!(number: params[:week_id]) rescue Week.find(params[:week_id])
  end

  def set_article
    @article = @week.articles.find(params[:id])
  end

  def article_params
    permitted = params.require(:article).permit(:title, :description, :body, :cover_image, :tag_list)
    permitted[:tags] = Article.parse_tags(permitted.delete(:tag_list)) if permitted.key?(:tag_list)
    permitted
  end
end


