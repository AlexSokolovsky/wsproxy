# frozen_string_literal: true

require './ws_storage'

module AutoUnbind
  HOUR_IN_SECONDS = 3600
  DEFAULT_TIME_LEFT = 4
  def auto_unbind
    return unless start_time
    # To convert time from seconds to hours devide by 3600. TIME_LEFT - compared time in hours
    return unless (Time.now.gmtime.to_i - start_time) / HOUR_IN_SECONDS >= ENV['TIME_LEFT'].to_i || DEFAULT_TIME_LEFT
    WSStorage::STORAGE['b_pairs'].delete_if { |_k, v| v == @query.chip_id }
    WSStorage::STORAGE['time_start'].delete('start_time')
  end

  def start_time
    WSStorage.get('time_start')['start_time']
  end
end

class MessageHandler
  include AutoUnbind
  def initialize(params)
    @remote = params[:remote]
    @msg = params[:msg]
    @query = params[:query]
    @b_pairs = params[:b_pairs]
    @appliances = params[:appliances]
    @ws = params[:ws]
    @users = params[:users]
    @from =  @users[@query.uid] ? "USER #{@query.uid}" : "DEVICE #{@query.chip_id}"
    @message = {}
    @logger = params[:logger]
  end

  def message
    reply_on_connect
    @logger.debug("---Message from ip #{@remote} received from #{@from}")
    @logger.debug(@msg.data)
  end

  def reply_on_connect
    case role
    when 'user'
      return available_commands_for_unbinded_device unless bind_device?
      available_commands_for_binded_device
    when 'device'
      return auto_unbind unless device_binded_to_user?
      @device.send(@msg.data)
      @logger.debug(
        "Sending message '#{@msg.data}' from DEVICE #{@query.chip_id}"\
        " to USER: #{b_pair_key}. Remote: #{@remote}"
      )
    end
  end

  def available_commands_for_binded_device
    return select_user_for_device unless @msg.data == 'Unbind'
    return unbind_device_error unless (device = WSStorage.get('b_pairs', @query.uid))
    unbind_device(device)
  end

  def unbind_device(device)
    @ws.send({ 'bind' => false }.to_json)
    @logger.debug("Unbind SENSOR #{device} for USER #{@query.uid}. Remote: #{@remote}")
    WSStorage.clear('b_pairs', @query.uid)
  end

  def unbind_device_error
    @ws.send({ 'Error' => 'Error! Something goes wrong when trying unbind device' }.to_json)
    @logger.error(
      'Error! Something goes wrong when trying unbind DEVICE '\
      " for USER #{@query.uid}. Remote: #{@remote}"
    )
  end

  def available_commands_for_unbinded_device
    case @msg.data
    when 'Get AvailableApplianceList'
      device_list
    when /\A(Bind me with)/
      bind_select_device
    when 'Unbind'
      @message = { 'Error' => 'Error! You dont have binded device' }.to_json
      @ws.send(@message)
      @logger.error(@message)
    end
  end

  def device_list
    @message['devices'] = @appliances.keys.reject { |k| @b_pairs.value?(k) }
    @ws.send(@message.to_json)
  end

  def bind_select_device
    device = @msg.data[/\d+/]
    return bind_device(device) if @appliances.keys.include?(device)
    @message = { 'Error' => "Error! Can't bind you with this device. Try another one, or make it later" }.to_json
    @ws.send(@message)
    @logger.error(@message)
  end

  def bind_device(wanted_device)
    if @b_pairs.value?(wanted_device)
      @message = { 'Error' => "Error! Can't bind you with this device. Try another one, or make it later" }
      @logger.error(@message)
    else
      @b_pairs[@query.uid] = wanted_device
      @message = { 'bind' => true }
    end
    @ws.send(@message.to_json)
  end

  def select_user_for_device
    if (user = @appliances[@b_pairs[@query.uid]])
      user.send(@msg.data)
      @logger.debug(
        "Sending message '#{@msg.data}' from USER #{@query.uid}"\
        "to DEVICE: #{@b_pairs[@query.uid]}. Remote: #{@remote}"
      )
    else
      @ws.send({ 'Error' => "Error! Can't send to this device." }.to_json)
      @logger.error(
        "Error! Can't send to the DEVICE #{@b_pairs[@query.uid]}. "\
        "Call from USER #{@query.uid}. Remote: #{@remote}"
      )
    end
  end

  def bind_device?
    return unless @b_pairs.key?(@query.uid)
    true
  end

  def device_binded_to_user?
    (@device = @users[b_pair_key]) && !@appliances.empty?
  end

  def b_pair_key
    @b_pairs.key(@query.chip_id)
  end

  def role
    @query.uid ? 'user' : 'device'
  end
end
