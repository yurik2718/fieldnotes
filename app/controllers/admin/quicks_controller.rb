class Admin::QuicksController < Admin::BaseController
  def new
    @field_series = FieldSeries.new
  end

  def create
    @field_series = FieldSeries.new(quick_params)
    if @field_series.save
      @field_series.append_photos(photos_params)
      redirect_to edit_admin_field_path(@field_series), notice: "Draft created — add details"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def quick_params
      params.expect(field_series: [ :title, :location ])
    end

    def photos_params
      Array(params[:field_series][:photos]).select(&:present?)
    end
end
