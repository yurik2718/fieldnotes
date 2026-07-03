class Admin::FieldItemsController < Admin::BaseController
  before_action :set_series
  before_action :set_item, only: [ :update, :destroy ]

  def create
    @item = @series.field_items.new(field_item_params)
    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_field_url(@series), notice: "Item added" }
      end
    else
      redirect_to admin_field_url(@series), alert: @item.errors.full_messages.to_sentence
    end
  end

  def update
    if @item.update(field_item_params)
      redirect_to admin_field_url(@series), notice: "Item updated"
    else
      redirect_to admin_field_url(@series), alert: @item.errors.full_messages.to_sentence
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_field_url(@series), notice: "Item deleted" }
    end
  end

  private
    def set_series
      @series = FieldSeries.find_by!(slug: params[:field_id])
    end

    def set_item
      @item = @series.field_items.find(params[:id])
    end

    def field_item_params
      params.expect(field_item: [ :kind, :caption, :position, :youtube_url, :photo ])
    end
end
