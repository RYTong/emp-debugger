net = require("net")
emp_server = null
emp_socket_map = {}
module.exports =
class emp_socket
  server_state: false
  timeout = 14400000

  constructor: ->
    console.log "init socket~"


    # console.log "content: #{content}"
    # argsScript = message.split "#EditorScript#"
    #
    # numOfScript = parseInt(argsScript.length / 3)
    # # // console.log(numOfScript);
    #
    # scripts = []
    # for i in  [0..numOfScript-1]
    # 	scripts.push(argsScript[1+3*i])
    #
    # contentAndScripts = content
    # for s_con in scripts
    # 	contentAndScripts = contentAndScripts + "#&#" + s_con
    # console.log "contentAndScripts: #{contentAndScripts}"

  init_call: (socket) ->
    isConnected = true

    remotePort = socket.remotePort
    console.log "client #{remotePort} connect : #{socket.remoteAddress} #{remotePort}"
    socket.setEncoding 'utf8'
    emp_socket_map[remotePort] = socket

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
          dealWithMessageFromTarget(data)
        else
          buffers += data
      else
        if (String(data).lastIndexOf(endStr) == String(data).length - String(endStr).length - tailFlag)
          buffers += data
          dealWithMessageFromTarget(buffers)
          buffers = ''
        else
          buffers += data

    #  socket断开的处理方法
    socket.on 'close', (data) ->
      console.log 'close socket----------:', remotePort
      emp_socket_map[remotePort] = null
      delete emp_socket_map[remotePort]

    socket.setTimeout @timeout,  ->
      console.log( '连接超时')
      socket.end()



  init: (ip, socket_port) ->
    console.log "socket server initial"
    emp_server = net.createServer @init_call
    .listen(socket_port, ip) #// 开始监听

    emp_server.on 'listening', ->
      console.log '\nSocket Server For Target-> ' + emp_server.address().address + ":" +emp_server.address().port

    # // socket错误状态
    emp_server.on 'error', (exception) ->
      emp_socket_map = {}

  get_socket_length: ->
    len=0
    for x, s of emp_socket_map
      console.log x
      console.log s
      if (s isnt null)
        len=len+1
    return len


  debug: (con) ->
    # console.log "server: #{emp_server}"
    # console.log "emp_socket_map: #{emp_socket_map}"
    if emp_server
      # console.log "server:"+ get_socket_length()
      for p, socket_m of emp_socket_map
        # console.log "p : #{p},  s:#{socket_m}"
        socket_m.write('s2bContent&$' + con + '$&end')

    else
      console.log "server2"
      atom.confirm
        message:"Error"
        detailedMessage:"There's no socket server~"

  close: () ->
    console.log "close socket server"
    for p, socket_m of emp_socket_map
      console.log "close:p : #{p},  s:#{socket_m}"
      socket_m.end('$close')
    emp_socket_map = {}
    emp_server.close()
    emp_server_state = false
    emp_server = null
    console.log "close over"


  get_server: ->
    emp_server

  get_socket_map: ->
    emp_socket_map

dealWithMessageFromTarget = (data) ->
  # console.log "line: #{data}"
  dataList = []
  dataList = data.split "EditorMessageEnd"
  console.log "data: #{dataList}"
  dealWithOneMessage(key + "EditorMessageEnd") for key in dataList

  # (@dealWithOneMessage(content + "EditorMessageEnd") for content in dataList)
    # one = content + "EditorMessageEnd"
    # @dealWithOneMessage(one)

dealWithOneMessage = (message) ->
  # console.log "信息: #{message}"
  argsLog = message.split "#EditorLog#"
  if argsLog.length == 3
    logInfo = argsLog[1]
    # console.log "loginfo :#{logInfo}"
    return

  # console.log "message: #{message}"
  argsContent = message.split "#EditorContent#"
  content = argsContent[1]
