net = require("net")
emp_clients_map = require './emp_clients'
emp_client = require './emp_client'
emp_server = null
emp_server_error = null
# emp_socket_map = {}
# emp_view_map = {}
emp_client_map = null
log_storage = null
emp_server_state = false

module.exports =
class emp_socket

  timeout = 14400000


  constructor: (tmp_log_storage)->
    # console.log "init socket~"
    emp_client_map = new emp_clients_map()
    log_storage = tmp_log_storage

  init_call: (socket) ->
    isConnected = true
    remotePort = socket.remotePort
    console.log "New Client connect: #{socket.remoteAddress} #{remotePort}"
    socket.setEncoding 'utf8'

    emp_client_map.new_client(remotePort, socket)

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
      # emp_socket_map[remotePort] = null
      # delete emp_socket_map[remotePort]
      emp_client_map.remove_client_socket(remotePort)

    socket.setTimeout @timeout,  ->
      console.log( 'Client connect timeout~')
      socket.end()

  init: (ip, socket_port) ->
    # console.log "socket server initial"
    emp_server_error = null
    emp_server = net.createServer @init_call

    # // socket错误状态
    emp_server.on 'error', (exception) ->
      # console.log exception
      if exception.code is 'EADDRINUSE'
        console.log('Address in use, retrying...');
        emp_server_state = false
        emp_server = null
        emp_server_error = 'EADDRINUSE'
        atom.confirm
          message:"Error"
          detailedMessage:"Address or Port in use, retrying..."

      emp_client_map.remove_all_client_socket()

    emp_server.listen(socket_port, ip) #// 开始监听
    emp_server.on 'listening', ->
      emp_server_state = true
      console.log '\nSocket Server start as:' + emp_server.address().address + ":" +emp_server.address().port

    # # // socket错误状态



  debug: (con) ->
    # console.log "server: #{emp_server}"
    # console.log "emp_socket_map: #{emp_socket_map}"
    if emp_server
      if emp_client_map.active_len > 0
        for socket_m in emp_client_map.get_all_socket()
          socket_m.write('s2bContent&$' + con + '$&end')
          console.log "live preview over~"
      else
        atom.confirm
          message:"Error"
          detailedMessage:"There's no active client~"

    else
      atom.confirm
        message:"Error"
        detailedMessage:"There's no socket server~"

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
        atom.confirm
          message:"Error"
          detailedMessage:"There's no socket server~"
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
  # console.log "message~~: #{message}"

  if argsLog.length == 3
    # console.log "log~~: #{argsLog}"
    logInfo = argsLog[1]
    console.log "log: #{logInfo}"
    log_storage.store_log(client_id, logInfo)
    logInfo
    return

  # console.log "after log"
  argsContent = message.split "#EditorContent#"
  content = argsContent[1]
  emp_client_map.put_spec_view(client_id, content) unless content is undefined
