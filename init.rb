# -*- coding: utf-8 -*-
require 'redmine'

Redmine::Plugin.register :redmine_ical do
  name 'Redmine Ical plugin'
  author 'Ryuichi Kato'
  description 'iCal Support for Redmine'
  version '0.0.1'
  url 'https://github.com/ryu00026/redmine_ical'
  author_url 'http://d.hatena.ne.jp/ryu00026/'


  menu :account_menu,
  :ical_settings, {
    :controller => 'ical_settings',
    :action => 'index'
  },
  :caption => 'iCal設定',
  :last => true
end
