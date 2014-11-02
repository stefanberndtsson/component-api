class ComponentsController < ApplicationController
  before_filter :validate_token, only: [:create, :update]

  def index
    @components = Component.paginate(page: params[:page])
    if @components.current_page > @components.total_pages
      @components = Component.paginate(page: 1)
    end
    @components = @components.order(:name)
    pagination = {}
    pagination[:pages] = @components.total_pages
    pagination[:page] = @components.current_page
    pagination[:next] = @components.next_page
    pagination[:previous] = @components.previous_page
    render json: {components: @components, meta: {pagination: pagination}}
  end
  
  def show
    @component = Component.find_by_id(params[:id])
    if @component.nil?
      render json: {meta: { errors: "Component #{params[:id]} not found"}}, status: 404
    else
      render json: {component: @component}
    end
  end
  
  def create
    @component = Component.new(params_permitted)
    if @component.save
      if params[:component][:tags]
        params[:component][:tags].each do |tag_name|
          @component.add_tag(tag_name)
        end
      end
      render json: {component: @component}
    else
      render json: { errors: @component.errors }, status: 422
    end
  end
  
  def update
    @component = Component.find_by_id(params[:id])
    if @component.nil?
      render json: {meta: { errors: "Component #{params[:id]} not found"}}, status: 404
      return
    end
    
    if @component.update_attributes(params_permitted)
      if params[:component][:tags]
        @component.clear_tags
        params[:component][:tags].each do |tag_name|
          @component.add_tag(tag_name)
        end
      end
    
      render json: {component: @component}
    else
      render json: {errors: @component.errors }, status: 422
    end
  end
  
  private
  def params_permitted
    params.require(:component).permit(:name, :description, :amount_id, :amount_value, :spares)
  end
end
