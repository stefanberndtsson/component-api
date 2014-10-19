class SearchesController < ApplicationController
  def index
    @results = Component.search(params[:query])
    pagination = {}
    if !@results.empty?
      tmp = @results.paginate(page: params[:page])
      if tmp.current_page > tmp.total_pages
        @results = @results.paginate(page: 1)
      else
        @results = tmp
      end
      @results = @results.order(:name)
      pagination[:pages] = @results.total_pages
      pagination[:page] = @results.current_page
      pagination[:next] = @results.next_page
      pagination[:previous] = @results.previous_page
    else
      pagination[:pages] = 0
      pagination[:page] = 0
      pagination[:next] = nil
      pagination[:previous] = nil
    end
    metaquery = {}
    metaquery[:query] = params[:query]
    metaquery[:total] = @results.count
    render json: {results: @results, meta: { query: metaquery, pagination: pagination }}
  end
end
