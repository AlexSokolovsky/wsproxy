# frozen_string_literal: true

require './ws_storage'
require './message_handler'

Faye::WebSocket.load_adapter('thin')
@logger = Logger.new(ENV['LOGFILE'] || 'example.log')

App = lambda do |env|
  return [404, { 'Content-Type' => 'text/plain' }, ['Not Found!']]\
  unless Faye::WebSocket.websocket?(env)
  ws = Faye::WebSocket.new(env)
  query = OpenStruct.new(Rack::Utils.parse_query(env['QUERY_STRING']))
  remote = env['REMOTE_ADDR']
  params = if (uid = query.uid)
             ['users', { uid => ws }]
           elsif (chip_id = query.chip_id)
             ['appliances', { chip_id => ws }]
           end
  WSStorage.set(*params)

  ws.on :open do
    message = if (chip_id = WSStorage.get('b_pairs')[query.uid])
                { 'binded_device' => chip_id }
              else
                { 'connection' => 'true' }
              end.to_json
    ws.send(message)
    @logger.debug("WebSocket opened from #{remote}")
  end

  ws.on :message do |msg|
    params = {
      msg: msg,
      ws: ws,
      query: query,
      logger: @logger,
      remote: remote,
      users: WSStorage.get('users'),
      appliances: WSStorage.get('appliances'),
      b_pairs: WSStorage.get('b_pairs')
    }
    MessageHandler.new(params).message
  end

  ws.on :close do |e|
    WSStorage.set('time_start', 'start_time' => Time.now.gmtime.to_i)
    WSStorage.clear('users', query.uid) if query.uid
    @logger.error([:close, e.code, e.reason, remote])
    ws = nil
  end

  ws.rack_response
end
