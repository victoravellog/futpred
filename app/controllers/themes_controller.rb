class ThemesController < ApplicationController
  def update
    Current.user.update!(theme: params[:theme])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("theme-selector", partial: "shared/theme_selector")
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
