# == Schema Information
# Schema version: 85
#
# Table name: exim_log_dones
#
#  id         :integer         not null, primary key
#  filename   :text            not null
#  last_stat  :datetime        not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

# models/exim_log_done.rb:
# Stores that a particular exim file has been loaded in, see exim_log.rb
#
# Copyright (c) 2009 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: exim_log_done.rb,v 1.8 2009-09-17 21:10:05 francis Exp $

class EximLogDone < ActiveRecord::Base
    has_many :exim_logs
end



