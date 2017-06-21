# encoding: utf-8
class Admin::EmailsController < Admin::AdminBaseController

  def new
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "email_members"
  end

  def create
    content = params[:email][:content].gsub(/[”“]/, '"') if params[:email][:content] # Fix UTF-8 quotation marks
    Delayed::Job.enqueue(CreateMemberEmailBatchJob.new(@current_user.id, @current_community.id, params[:email][:subject], content, params[:email][:locale]))
    flash[:notice] = t("admin.emails.new.email_sent")
    redirect_to :action => :new
  end

end
