class Admin::ArticlesController < Admin::BaseController
  before_action :set_day
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @articles = pagy(@day.articles.order(:created_at), items: 20)
    authorize! :read, Article
  end

  def show
    authorize! :read, @article
  end

  def new
    @article = @day.articles.new
    authorize! :create, @article
  end

  def create
    @article = @day.articles.new(article_params)
    authorize! :create, @article
    if @article.save
      redirect_to admin_day_article_path(@day, @article), notice: 'Статья создана'
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
    if @article.update(article_params)
      redirect_to admin_day_article_path(@day, @article), notice: 'Статья обновлена'
    else
      flash.now[:alert] = @article.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @article
    @article.destroy
    redirect_to admin_day_articles_path(@day), notice: 'Статья удалена'
  end

  private

  def set_day
    @day = Day.find_by!(number: params[:day_id]) rescue Day.find(params[:day_id])
  end

  def set_article
    @article = @day.articles.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body)
  end
end


