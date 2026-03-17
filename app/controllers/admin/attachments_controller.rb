module Admin
  class AttachmentsController < BaseController
    def destroy
      @attachment = ActiveStorage::Attachment.find(params[:id])
      authorize @attachment
      @attachment.purge
      
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@attachment) }
        format.html { redirect_back(fallback_location: admin_root_path, notice: "Attachment deleted.") }
      end
    end
  end
end
