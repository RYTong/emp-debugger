net = require("net")
emp_clients_map = require './emp_clients'
emp_client = require './emp_client'
emp = require '../exports/emp'
emp_server = null
emp_server_error = null
# emp_socket_map = {}
# emp_view_map = {}
emp_client_map = null
log_storage = null
emp_server_state = false
emp_conf_view = null
module.exports =
class emp_socket

  timeout = 14400000
  default_host: 'default'
  default_port: '7003'


  constructor: (tmp_log_storage)->
    # console.log "init socket~"
    emp_client_map = new emp_clients_map(tmp_log_storage)
    log_storage = tmp_log_storage

  set_conf_view: (tmp_conf_view)->
    emp_conf_view = tmp_conf_view

  init_call: (socket) ->
    isConnected = true
    remotePort = socket.remotePort
    console.log "New Client connect: #{socket.remoteAddress} #{remotePort}"
    socket.setEncoding 'utf8'

    emp_client_map.new_client(remotePort, socket) #创建新的client 对象
    emp_conf_view.refresh_state_pane_ln() unless !emp_conf_view# 刷新状态页面链接数量

    buffers = ''
    #  设置监听--接受消息的方法
    socket.on 'data', (data) ->
      #  console.log('recv:' + data);
      endStr = "EditorMessageEnd"  # 信息结束标志
      tailFlag = 0  #字符串结尾再减一
      tailChar = data.substr -1, 1 # 取得data最后一个字符
      if tailChar == '\0'
        tailFlag = 1
      if String(data).indexOf("EditorMessageStart") == 0  # data以"EditorMessageStart"开头
        if (String(data).lastIndexOf(endStr) == String(data).length - String(endStr).length - tailFlag)
          dealWithMessageFromTarget(data, remotePort)
        else
          buffers += data
      else
        if (String(data).lastIndexOf(endStr) == String(data).length - String(endStr).length - tailFlag)
          buffers += data
          dealWithMessageFromTarget(buffers, remotePort)
          buffers = ''
        else
          buffers += data

    #  socket断开的处理方法
    socket.on 'close', (data) ->
      console.log 'Client close:', remotePort
      emp_client_map.remove_client_socket(remotePort) # 清除client 的socket状态
      # log_storage.remove_client_log(remotePort) # 清除
      emp_conf_view.remove_client(remotePort) unless !emp_conf_view


    socket.setTimeout @timeout,  ->
      console.log( 'Client connect timeout~')
      socket.end()

  init: (ip, socket_port) ->
    # console.log "socket server initial"
    emp_server_error = null
    emp_server = net.createServer @init_call
    # // socket错误状态
    emp_server.on 'error', (exception) ->
      if exception.code is 'EADDRINUSE'
        console.log('Address in use, retrying...');
        emp_server_state = false
        emp_server = null
        emp_server_error = 'EADDRINUSE'
        emp.show_error("Address or Port in use, retrying...")
        emp_conf_view.hide_state_pane() unless !emp_conf_view
      emp_client_map.remove_all_client_socket()

    if ip is @default_host
      emp_server.listen(socket_port) #// 开始监听
    else
      emp_server.listen(socket_port, ip) #// 开始监听
    emp_server.on 'listening', ->
      emp_server_state = true
      console.log '\nSocket Server start as:' + emp_server.address().address + ":" +emp_server.address().port
      emp_conf_view.hide_conf_pane() unless !emp_conf_view

  # live preview lua file
  live_preview_lua: (script_name, script_con) ->
    if emp_server
      if emp_client_map.active_len > 0
        live_con =  "s2bContent&$#{@get_view_con()}#&##{script_name}#fileName##{script_con}$&end"
        for socket_m in emp_client_map.get_all_socket()
          socket_m.write(live_con)
        @send_content_to_all(live_con)
      else
        @no_client_err()
    else
      @no_server_err()

  get_view_con: ->
    view_obj = emp_client_map.get_lastest_view()
    view_obj.view

  live_preview_view: (view_con, script_con, debug_script_name) ->
    # console.log "server: #{emp_server}"
    # console.log "emp_socket_map: #{emp_socket_map}"
    if emp_server
      if emp_client_map.active_len > 0
        live_con = ''
        if script_con
          live_con =  "s2bContent&$#{view_con}#&##{debug_script_name}#fileName##{script_con}$&end"
        else
          live_con =  "s2bContent&$#{view_con}$&end"
        # console.log "con:#{live_con}"
        @send_content_to_all(live_con)
        console.log "live preview over~"
      else
        @no_client_err()
    else
      @no_server_err()

  # send msg to all client
  send_content_to_all: (msg) ->
    for socket_m in emp_client_map.get_all_socket()
      socket_m.write(msg)

  # alert a no active client warnning~
  no_client_err: ->
    emp.show_error("There's no active client~")

  no_server_err: ->
    emp.show_error("There's no socket server~")

  # alert a no socket server warnning~
  close: () ->
    console.log "close socket server"
    # console.log emp_server
    try
      if emp_server
        emp_client_map.get_all_socket()
        emp_client_map.close_all_socket()
        # emp_socket_map = {}
        emp_server.close()
        emp_server_state = false
        emp_server = null
        emp_server_error = null
        console.log "close socket sever over"
      else
        @no_server_err()
    catch exc
      # console.log exc
      emp_server_state = false
      emp_server = null
      emp_server_error = null


  get_server: ->
    emp_server

  get_client_map: ->
    emp_client_map

  get_enable_view_list: ->
    emp_view_map

  get_server_error: ->
    emp_server_error

  get_server_sate: ->
    emp_server_state

  get_default_host: ->
    @default_host

  get_default_port: ->
    @default_port

  reset_server: ->
    emp_server_state = false
    emp_server = null
    emp_server_error = null

dealWithMessageFromTarget = (data, client_id) ->
  # console.log "line: #{data}"
  dataList = []
  dataList = data.split "EditorMessageEnd"
  dealWithOneMessage(key + "EditorMessageEnd", client_id) for key in dataList

dealWithOneMessage = (message, client_id) ->
  # console.log "信息: #{message}"
  argsLog = message.split "#EditorLog#"

  if argsLog.length == 3
    logInfo = argsLog[1]
    log_storage.store_log(client_id, logInfo)
    logInfo
    return

  emp_client_map.store_view(client_id, message)
  # argsContent = message.split "#EditorContent#"
  # content = argsContent[1]
  # emp_client_map.put_spec_view(client_id, content) unless content is undefined
  #
  # script_arr = message.split "#EditorScript#"
  # script_len =  parseInt(script_arr.length / 3)
  # emp_client_map.procee_script(client_id, script_arr, script_len) unless script_len is 0
