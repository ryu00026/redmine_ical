# -*- coding: utf-8 -*-
class IcalSetting < ActiveRecord::Base
  unloadable

  validates_inclusion_of :past, :in => 1..30, :allow_nil => true
  validates_inclusion_of :future, :in => 1..30, :allow_nil => true
  validates_inclusion_of :time_number, :in => 1..100, :allow_nil => true
  validates_inclusion_of :time_section , :in=> %w(M H D)
  validates_inclusion_of :time_section , :in=> %w(M H D)
  validates_numericality_of :past
  validates_numericality_of :future
  validates_numericality_of :time_number
  validates_presence_of :past
  validates_presence_of :future
  validates_presence_of :time_section
  FLAGS  = [["ON",true],["OFF",false]]
  SECTIONS = [["分","M"],["時間","H"],["日","D"]]
  SECTION_LABEL = { "M" => "分", "H" => "時間", "D" => "日" }


  def self.authenticate(email, token)
    ical_setting = IcalSetting.find_by_token(token)
    unless ical_setting.blank?
      return ical_setting.user
    end
    return nil
  end

  before_create :set_token!
  def set_token!
    self.token = generate_token
  end

  def update_token
    set_token
  end

  private

  def generate_token
    a = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    code = (Array.new(20) { a[rand(a.size)] }).join
    code.crypt(Time.now.to_s)
    code
  end


end
