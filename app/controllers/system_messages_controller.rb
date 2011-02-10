class SystemMessagesController < ActionController::Base
  def dismiss
    message = SystemMessage.find(params[:id])
    message.update_attribute('dismissed', true)
    respond_to do |format|
      format.js {
        render :update do |page|
          page.remove "system_message_#{message.id}"
        end
      }
    end
  end
  
  def dismiss_all
    SystemMessage.all.each do |message|
      message.update_attribute('dismissed', true)
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.reload
        end
      }
    end
  end
  
end