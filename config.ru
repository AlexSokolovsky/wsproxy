# frozen_string_literal: true

require 'dotenv/load'
require 'thin'
require 'json'
require 'pry'
require 'faye/websocket'
require 'ostruct'
require 'eventmachine'
require './ws_storage.rb'
require './message_handler.rb'
require './app.rb'

run App
