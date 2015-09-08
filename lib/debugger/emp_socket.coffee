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
timeout = 14400000

old_start_str = "EditorMessageStart"
old_end_str = "EditorMessageEnd"
old_log_str = "#EditorLog#"
new_end_str = "#e#"
new_start_str = "#s#"
pre_view_name = "staticContent"
glo_pre_script = "script"
glo_pre_css = "css"
pre_name = "name"
pre_content = "content"


module.exports =
class emp_socket

  default_host: 'default'
  default_port: '7003'

  constructor: (tmp_log_storage)->
    # console.log "init socket~"
    emp_client_map = new emp_clients_map(tmp_log_storage)
    log_storage = tmp_log_storage
    log_storage.set_socket_server(this)

  set_conf_view: (tmp_conf_view)->
    emp_conf_view = tmp_conf_view

  init_call: (socket) ->
    isConnected = true
    remotePort = socket.remotePort
    console.log "New Client connect: #{socket.remoteAddress} #{remotePort}"
    socket.setEncoding 'utf8'

    new_client = emp_client_map.new_client(remotePort, socket) #创建新的client 对象
    emp_conf_view.refresh_state_pane_ln() unless !emp_conf_view# 刷新状态页面链接数量
    log_storage.add_clients(remotePort)

    buffers = ''
    #  设置监听--接受消息的方法
    socket.on 'data', (data) ->
      #  console.log('recv:' + data);
      tailFlag = 0  #字符串结尾再减一
      tailChar = data.substr -1, 1 # 取得data最后一个字符
      if tailChar == '\0'
        tailFlag = 1
      # console.log data
      # console.log buffers

      if String(data).indexOf(old_start_str) == 0  # data以"EditorMessageStart"开头
        #  标示是否为新协议

        data_flag = false
        if (String(data).lastIndexOf(old_end_str) == String(data).length - String(old_end_str).length - tailFlag)
          deal_with_msg_detail(data_flag, data, remotePort, new_client)
        else
          buffers += data
      else if String(data).indexOf(new_start_str) == 0  # data以"#s#"开头
        data_flag = true
        if (String(data).lastIndexOf(new_end_str) == String(data).length - String(new_end_str).length - tailFlag)
          deal_with_msg_detail(data_flag, data, remotePort, new_client)
        else
          buffers += data
      else
        if (String(data).lastIndexOf(old_end_str) == String(data).length - String(old_end_str).length - tailFlag)
          buffers += data
          deal_with_msg_detail(data_flag=false, buffers, remotePort, new_client)
          buffers = ''
        else if (String(data).lastIndexOf(new_end_str) == String(data).length - String(new_end_str).length - tailFlag)
          buffers += data
          deal_with_msg_detail(data_flag=true, buffers, remotePort, new_client)
          buffers = ''
        else
          buffers += data
    #  socket断开的处理方法
    socket.on 'close', (data) ->
      console.log 'Client close:', remotePort
      emp_client_map.remove_client_socket(remotePort) # 清除client 的socket状态
      # log_storage.remove_client_log(remotePort) # 清除
      emp_conf_view.remove_client(remotePort) unless !emp_conf_view


    console.log timeout
    socket.setTimeout timeout,  ->
      console.log( 'Client connect timeout~')
      socket.end()

  init: (ip, socket_port) ->
    # console.log "socket server initial"
    emp_server_error = null
    emp_server = net.createServer @init_call
    # // socket错误状态
    emp_server.on 'error', (exception) ->
      if exception.code is 'EADDRINUSE'
        console.error('Address in use, retrying...');
        emp_server_state = false
        emp_server = null
        emp_server_error = 'EADDRINUSE'
        emp.show_error("Address or Port in use, retrying...")
      else
        console.error "socket start error"
        console.error exception

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


  # #s#{
  #     "staticContent": "报文内容(经过Base64编码)",
  #     "css": [
  #         {
  #             "name": "外联样式1名称",
  #             "content": "外联样式1内容(经过Base64编码)"
  #         },
  #         {
  #             "name": "外联样式2名称",
  #             "content": "外联样式2内容(经过Base64编码)"
  #         }
  #     ],
  #     "script": [
  #         {
  #             "name": "外联脚本1名称",
  #             "content": "外联脚本1内容(经过Base64编码)"
  #         },
  #         {
  #             "name": "外联脚本2名称",
  #             "content": "外联脚本2内容(经过Base64编码)"
  #         }
  #     ]
  # }#e#
  live_preview_view: (view_con, script_con, debug_script_name) ->
    # console.log "server: #{emp_server}"
    # console.log "emp_socket_map: #{emp_socket_map}"
    preview_obj = {}
    preview_obj[pre_view_name] = emp.base64_encode view_con
    if emp_server
      if emp_client_map.active_len > 0
        old_live_con = ''

        if script_con
          preview_obj[glo_pre_script] = []
          tmp_script = @new_preview_obj(debug_script_name, script_con)
          preview_obj[glo_pre_script].push tmp_script
          # 兼容老协议内容
          old_live_con =  "s2bContent&$#{view_con}#&##{debug_script_name}#fileName##{script_con}$&end"
        else
          # 兼容老协议内容
          old_live_con =  "s2bContent&$#{view_con}$&end"

        preview_json_str = JSON.stringify preview_obj
        preview_json_str = new_start_str+preview_json_str+new_end_str
        # console.log "preview_json_str:#{preview_json_str}"
        @send_content_to_all(preview_json_str, old_live_con)
        console.log "live preview over~"
      else
        @no_client_err()
    else
      @no_server_err()

  live_preview_view_with_new: (view_obj, debug_text) ->
    # console.log view_obj
    preview_obj = {}
    old_live_con = ''
    # console.log "debug text"
    # console.log debug_text
    # OFF_EXTENSION_XHTML:"xhtml"
    # OFF_EXTENSION_LUA:"lua"
    # OFF_EXTENSION_CSS: "css"
    if emp_server
      if emp_client_map.active_len > 0
        switch view_obj.file_type
          when emp.OFF_EXTENSION_LUA
            preview_obj[glo_pre_script] = []
            tmp_script = @new_preview_obj(view_obj.input_name, debug_text)
            preview_obj[glo_pre_script].push tmp_script
            debug_view = view_obj.get_fa_obj().view
            # console.log debug_view
            preview_obj[pre_view_name] = emp.base64_encode debug_view
            old_live_con =  "s2bContent&$#{debug_view}#&##{view_obj.name}#fileName##{debug_text}$&end"
          when emp.OFF_EXTENSION_CSS
            # console.log "thi is a css"
            preview_obj[glo_pre_css] = []
            tmp_css = @new_preview_obj(view_obj.input_name, debug_text)
            preview_obj[glo_pre_css].push tmp_css
            debug_view = view_obj.get_fa_obj().view
            # console.log debug_view
            preview_obj[pre_view_name] = emp.base64_encode debug_view
            old_live_con =  "s2bContent&$#{debug_view}$&end"
          else
            # console.log debug_text
            preview_obj[pre_view_name] = emp.base64_encode debug_text
            old_live_con =  "s2bContent&$#{debug_text}$&end"
        preview_json_str = JSON.stringify preview_obj
        preview_json_str = new_start_str+preview_json_str+new_end_str
        # console.log "preview_json_str:#{preview_json_str}"
        @send_content_to_client(preview_json_str, old_live_con, view_obj.fa_from)
        # console.log "live preview over~"
      else
        @no_client_err()
    else
      @no_server_err()

  # live preview lua file
  live_preview_lua: (script_name, script_con) ->
    view_con = @get_view_con()
    preview_obj = {}
    preview_obj[pre_view_name] = emp.base64_encode view_con
    if emp_server
      if emp_client_map.active_len > 0
          preview_obj[glo_pre_script] = []
          tmp_script = @new_preview_obj(script_name, script_con)
          preview_obj[glo_pre_script].push tmp_script
          preview_json_str = JSON.stringify preview_obj
          preview_json_str = new_start_str+preview_json_str+new_end_str
          # 兼容老协议内容
          old_live_con =  "s2bContent&$#{view_con}#&##{script_name}#fileName##{script_con}$&end"
          @send_content_to_all(preview_json_str, old_live_con)
      else
        @no_client_err()
    else
      @no_server_err()

  get_view_con: ->
    view_obj = emp_client_map.get_lastest_view()
    view_obj.view

  new_preview_obj:(name, con) ->
    {"name":name, "content":emp.base64_encode con}


  # send msg to all client
  send_content_to_all: (new_msg, old_msg) ->
    all_socket = emp_client_map.get_all_socket()
    new_p_socket = all_socket.new_p
    old_p_socket = all_socket.old_p
    unless !new_msg
      for socket_m in new_p_socket
        socket_m.write(new_msg)
    unless !old_msg
      for socket_o in old_p_socket
        socket_o.write(old_msg)

  send_content_to_client: (new_msg, old_msg, client_id)->
    # console.log client_id
    client_socket = emp_client_map.get_client_socket(client_id)
    if client_socket
      client_socket.write(new_msg)
    else
      all_socket = emp_client_map.get_all_socket()
      new_p_socket = all_socket.new_p
      old_p_socket = all_socket.old_p
      unless !new_msg
        for socket_m in new_p_socket
          socket_m.write(new_msg)
      unless !old_msg
        for socket_o in old_p_socket
          socket_o.write(old_msg)


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
        # emp_client_map.get_all_socket()
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

  get_all_id: ->
    emp_client_map.get_all_id()

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


  send_lua_console: (lua_code, client_id) ->
    if lua_code
      lua_obj = {"lua_console": emp.base64_encode lua_code}
      lua_json_str = JSON.stringify lua_obj
      lua_json_str = new_start_str+lua_json_str+new_end_str
      all_socket = emp_client_map.get_all_socket()
      new_p_socket = all_socket.new_p
      # console.log lua_json_str
      # console.log new_p_socket
      for socket_m in new_p_socket
        socket_m.write(lua_json_str)
    else
      console.log "do nothing"
  # argsContent = message.split "#EditorContent#"
  # content = argsContent[1]
  # emp_client_map.put_spec_view(client_id, content) unless content is undefined
  #
  # script_arr = message.split "#EditorScript#"
  # script_len =  parseInt(script_arr.length / 3)
  # emp_client_map.procee_script(client_id, script_arr, script_len) unless script_len is 0

  # @DOC 新协议格式
  # #s#{
  #     "originMessage": {
  #         "staticContent": "报文内容(经过Base64编码)",
  #         "css": [
  #             {
  #                 "name": "外联样式1名称",
  #                 "content": "外联样式1内容(经过Base64编码)"
  #             },
  #             {
  #                 "name": "外联样式2名称",
  #                 "content": "外联样式2内容(经过Base64编码)"
  #             }
  #         ],
  #         "script": [
  #             {
  #                 "name": "外联脚本1名称",
  #                 "content": "外联脚本1内容(经过Base64编码)"
  #             },
  #             {
  #                 "name": "外联脚本2名称",
  #                 "content": "外联脚本2内容(经过Base64编码)"
  #             }
  #         ]
  #     },
  #     "expandedMessage": {
  #         "staticContent": "报文内容(经过Base64编码)",
  #         "css": [
  #             {
  #                 "name": "外联样式1名称",
  #                 "content": "外联样式1内容(经过Base64编码)"
  #             },
  #             {
  #                 "name": "外联样式2名称",
  #                 "content": "外联样式2内容(经过Base64编码)"
  #             }
  #         ],
  #         "script": [
  #             {
  #                 "name": "外联脚本1名称",
  #                 "content": "外联脚本1内容(经过Base64编码)"
  #             },
  #             {
  #                 "name": "外联脚本2名称",
  #                 "content": "外联脚本2内容(经过Base64编码)"
  #             }
  #         ]
  #     }
  # }#e#


deal_with_msg_detail =(data_flag=false, data, client_id, new_client) ->
  new_client.set_protocal_type(data_flag)
  console.log data
  if !data_flag
    dealWithMessageFromTarget(data, client_id)
  else
    deal_with_msg_from_new_pro(data, client_id)

dealWithMessageFromTarget = (data, client_id) ->
  # console.log "line: #{data}"

  dataList = []
  dataList = data.split old_end_str
  dealWithOneMessage(key + old_end_str, client_id) for key in dataList


dealWithOneMessage = (message, client_id) ->
  # console.log "+++++++++++++++++++++++++++dealWithOneMessage+++++++++++++++++++++++++++++"
  # console.log "信息: #{message}"
  # console.log "--------- message log -----------"
  # console.log message
  argsLog = message.split old_log_str
  # console.log argsLog
  # console.log argsLog
  if argsLog.length == 3
    logInfo = argsLog[1]
    log_storage.store_log(client_id, logInfo)
  emp_client_map.store_view(client_id, message)

deal_with_msg_from_new_pro = (data, client_id) ->
  # console.log data
  # "#s#{     \"originMessage\": {          \"staticContent\": \"asdasdasd\"}  }#e#"
  dataList = []
  dataList = data.split new_end_str
  # console.log dataList
  for tmp_con in dataList
    if tmp_con.trim().length > 2
      deal_with_detail_msg_from_new_pro(tmp_con, client_id)

deal_with_detail_msg_from_new_pro = (detai_msg, client_id) ->
  console.log detai_msg
  new_data = detai_msg.split new_start_str
  console.log new_data
  result_con = ""
  for tmp_con in new_data
    if tmp_con?.trim().length > 2
      # result_con = tmp_con
      try
        result_obj = JSON.parse tmp_con
        if result_obj["level"]
          log_storage.store_new_log(client_id, result_obj)
        else
          emp_client_map.store_new_view(client_id, result_obj)
      catch err
        console.error err
