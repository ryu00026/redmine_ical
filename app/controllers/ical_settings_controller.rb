# -*- coding: utf-8 -*-
class IcalSettingsController < ApplicationController
  unloadable
  before_filter :require_login
  before_filter :set_current_setting

  def index
  end

  def update
    @ical_setting.attributes = params[:ical_setting]
    unless @ical_setting.valid?
      render :index
      return
    else
      @ical_setting.save
      redirect_to :controller => "ical_settings", :action => "index"
      return
    end
  end

  def update_key
    @ical_setting.set_token!
    @ical_setting.save
    redirect_to :controller => "ical_settings", :action => "index"
  end

  def destroy
    @ical_setting.destroy
    redirect_to :controller => "ical_settings", :action => "index"
  end

  private
  def set_current_setting
    @user = User.current
    @ical_setting = IcalSetting.find(
      :first,
      :conditions => ["user_id = ?", @user.id]) || IcalSetting.new
    @ical_setting.user_id = @user.id
  end

end
