# -*- coding: utf-8 -*-
require "icalendar"
class ExportsController < ApplicationController
  unloadable
  skip_before_filter :check_if_login_required
  def ical
    ical_setting = IcalSetting.find(:first, :conditions => [" token = ? ", params[:id]])
    user = User.find(ical_setting.user_id)
     if ical_setting
      render :text => generate_ical(ical_setting, user)
    else
      render :text => "403", :status => :forbidden
    end
  end

  def generate_ical(ical_setting, user)
    today = Date.today
    startdt = today - ical_setting.past
    enddt = today + ical_setting.future

    #watchers = []
    #watch_users = []
    #Watcher.find(:all,
    #  :joins => "LEFT JOIN users ON watchers.user_id = users.id", :conditions => ["watchers.user_id = ? AND watchers.watchable_type = ?", user.id, "Issue"]).each do  |watcher|
    #  watchers << watcher.watchable_id
    #  watch_users << watcher.user
    #end
    #issues = Issue.find(:all, :conditions => ["start_date >= ? AND due_date <= ? AND (priority_id = ? OR id IN (?) )", startdt, enddt, user.id, watchers.uniq])

    # 未完了で自分の担当のチケットを取得
    issues = Issue.find(:all, :joins => "LEFT JOIN issue_statuses AS st ON issues.status_id = st.id", :conditions => ["issues.start_date >= ? AND issues.due_date <= ? AND issues.priority_id = ? AND st.is_closed = ?", startdt, enddt, user.id, false])

    cal = Icalendar::Calendar.new
    # タイムゾーン (VTIMEZONE) を作成
    cal.timezone do
      tzid 'Asia/Tokyo'
      standard do
        tzoffsetfrom '+0900'
        tzoffsetto   '+0900'
        dtstart      '19700101T000000'
        tzname       'JST'
      end
    end

    ical_name = "Redmine Issue Calender(#{user.name})"
    cal.custom_property("X-WR-CALNAME", ical_name)
    cal.custom_property("X-WR-CALDESC", ical_name)
    cal.custom_property("X-WR-TIMEZONE","Asia/Tokyo")
    cal.prodid("Redmine iCal Plugin")
    issues.each do |issue|
      s  = issue.start_date
      e  = issue.due_date

      event = Icalendar::Event.new
      event.summary = issue.subject

      # 終日だとhour,minは不要
      # 終日だと開始日の次の日
      event.dtstart = Date.new(s.year, s.month, s.day)
      event.dtend = Date.new(e.year, e.month, e.day) + 1.day
      event.custom_property("CONTACT;CN=#{user.name}", "MAILTO:#{user.mail}")
      event.description = issue.description
      event.url("#{request.protocol}#{request.host_with_port}/issues/#{issue.id}")
      event.created(issue.created_on.strftime("%Y%m%dT%H%M%SZ"))
      event.last_modified(issue.updated_on.strftime("%Y%m%dT%H%M%SZ"))
      event.uid("#{issue.id}@example.com") #Defines a persistent, globally unique id for this item

      #event.klass("PRIVATE")
      # 作成者が参加者の中にいればAtendeeではなくorganizerにする
#       watch_users.each do |watcher|
#         if issue.priority_id
#           if watcher.id == issue.priority_id
#             event.custom_property("ORGANIZER;CN=#{watcher.name}", "MAILTO:#{watcher.mail}")
#             event.custom_property("ATTENDEE;ROLE=CHAIR;CN=#{watcher.name}", "MAILTO:#{watcher.mail}")
#           else
#             attendee = Attendee.new(watcher.mail, {"CN" => watcher.name})
#             event.custom_property attendee.property_name, attendee.value
#           end
#         else
#           if watcher.id == issue.author_id
#             event.custom_property("ORGANIZER;CN=#{watcher.name}", "MAILTO:#{watcher.mail}")
#             event.custom_property("ATTENDEE;ROLE=CHAIR;CN=#{watcher.name}", "MAILTO:#{watcher.mail}")
#           else
#             attendee = Attendee.new(watcher.mail, {"CN" => watcher.name})
#             event.custom_property attendee.property_name, attendee.value
#           end
#         end
#       end

      Watcher.find(:all,
        :joins => "LEFT JOIN users ON watchers.user_id = users.id"
        :conditions => ["watchers.watchable_type = ? AND watchers.watchable_id = ?", "Issue", issue.id]).each do  |watcher|
        user = watcher.user
        if user.id == issue.priority_id
          event.custom_property("ORGANIZER;CN=#{user.name}", "MAILTO:#{user.mail}")
          event.custom_property("ATTENDEE;ROLE=CHAIR;CN=#{user.name}", "MAILTO:#{user.mail}")
        else
          attendee = Attendee.new(user.mail, {"CN" => user.name})
          event.custom_property attendee.property_name, attendee.value
        end
      end


      # 設定値を見る
      if ical_setting
        if ical_setting.alerm
          # アラーム (VALARM) を作成 (複数作成可能)
          event.alarm do
            action      "DISPLAY"  # 表示で知らせる
            trigger     "-PT#{ical_setting.time_number}#{ical_setting.time_section}"    # -PT5M=5分前に, -PT3H=3時間前, -P1D=1日前
          end
        end
      end
      cal.add event
    end
    # iCalのContent-Typeが必要
    #self.headers['Content-Type'] = "text/calendar; charset=UTF-8"
    cal.publish
    cal.to_ical
  end

  class Attendee
    attr :mailto, true
    attr :params, true

    def initialize(mailto, params={})
      self.mailto = mailto
      self.params = params
    end

    def property_name
      param_str = ""
      params.each do |key, value|
        param_str << ";" if param_str.empty?
        param_str << "#{key}=#{value}"
      end
      "ATTENDEE#{param_str}"
    end

    def value
      "MAILTO:#{mailto}"
    end
  end

  class Organizer
    attr :mailto, true
    attr :params, true

    def initialize(mailto, params={})
      self.mailto = mailto
      self.params = params
    end

    def property_name
      param_str = ""
      params.each do |key, value|
        param_str << ";" if param_str.empty?
        param_str << "#{key}=#{value}"
      end
      "ATTENDEE#{param_str}"
    end

    def value
      "MAILTO:#{mailto}"
    end
  end



end

