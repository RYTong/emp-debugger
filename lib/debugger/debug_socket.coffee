net = require("net")
socket_map = {}
timeout = 14400000
server = null

DealWithMessageFromTarget = (data) ->
  # console.log "line: #{data}"
  dataList = []
  dataList = data.split "EditorMessageEnd"
  console.log "data: #{dataList}"
  DealWithOneMessage(key + "EditorMessageEnd") for key in dataList

	# (DealWithOneMessage(content + "EditorMessageEnd") for content in dataList)
		# one = content + "EditorMessageEnd"
		# DealWithOneMessage(one)

DealWithOneMessage = (message) ->
	# console.log "信息: #{message}"
	argsLog = message.split "#EditorLog#"
	if argsLog.length == 3
		logInfo = argsLog[1]
		# console.log "loginfo :#{logInfo}"
		return

	# console.log "message: #{message}"
	argsContent = message.split "#EditorContent#"
	content = argsContent[1]
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




init = (ip, socket_port) ->
  console.log "socket server initial"
  server = net.createServer (socket) ->
    isConnected = true

    remotePort = socket.remotePort
    console.log "client #{remotePort} connect : #{socket.remoteAddress} #{remotePort}"
    socket.setEncoding 'utf8'
    socket_map[remotePort] = socket

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
          DealWithMessageFromTarget(data)
        else
          buffers += data
      else
        if (String(data).lastIndexOf(endStr) == String(data).length - String(endStr).length - tailFlag)
          buffers += data
          DealWithMessageFromTarget(buffers)
          buffers = ''
        else
          buffers += data

    #  socket断开的处理方法
    socket.on 'close', (data) ->
    	console.log 'close socket----------:', remotePort
    	socket_map[remotePort] = null
    	delete socket_map[remotePort]
    	# socket_ = null;
      #
    	# if get_socket_length() == 0
    	# 	isConnected = false
    	# 	unless isConnected
    	# 		if ws_
    	# 			# // 如果ws处于连接状态,发送当前客户端的连接状态
    	# 			ws_.send 'state#ws#' + '未连接!'

    socket.setTimeout timeout,  ->
    	console.log( '连接超时')
    	socket.end()

  .listen(socket_port, ip) #// 开始监听

  server.on 'listening',  ->
  	console.log '\nSocket Server For Target-> ' + server.address().address + ":" +server.address().port

  # // socket错误状态
  server.on 'error', (exception) ->
  	socket_map = {}

get_socket_length = ->
	len = 0
	for x, s of socket_map
		if s
			len = len +1
	return len


debug = (con) ->
  console.log "server: #{server}"
  console.log "socket_map: #{socket_map}"
  if server
    console.log '123123123~~'
    # console.log "server:"+ get_socket_length()
    for p, socket_m of socket_map
      console.log "p : #{p},  s:#{socket_m}"
      socket_m.write('s2bContent&$' + con + '$&end')

  else
    console.log "server2"
    atom.confirm
      message:"Error"
      detailedMessage:"There's no socket server~"

close = () ->
  console.log "close socket server"
  for p, socket_m of socket_map
    console.log "close:p : #{p},  s:#{socket_m}"
    socket_m.end('$close')
  socket_m = {}
  server.close()
  console.log "close over"


module.exports =
  init:init
  debug:debug
  close:close
