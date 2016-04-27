c_process = require 'child_process'
os = require 'os'
emp = require '../exports/emp'
path = require 'path'
fs = require 'fs'

rel_erl_path = '../../erl_util/'
iFlagLen = 8

module.exports =
class EmpErlIndent
  node_pid:null
  indent_editor:[]

  constructor: (serializeState) ->
    @iTabLen = atom.config.get(emp.EMP_ERL_INDENT_TAB_LEN)
    @bUseTab = atom.config.get(emp.EMP_ERL_INDENT_USE_TAB)
    @indent_editor=[]



  once_indent: ->
    oTextEditor = atom.workspace.getActiveTextEditor()
    unless oTextEditor
      return

    sFilePath = oTextEditor.getPath()
    sFileExt = path.extname(sFilePath ).toLowerCase() unless !sFilePath
    # console.log sFileExt
    unless sFileExt isnt emp.DEFAULT_EXT_ERL
      sSelectText = oTextEditor.getText()
      if oTextEditor.getSelectedText()
        console.log "---------- select text ------------"
        oBufferRange = oTextEditor.getSelectedBufferRanges()
        console.log oBufferRange

        # sSelectText = oTextEditor.getSelectedText()
        # console.log sSelectText
      # else
      #   console.log "---------- editor text ------------"
      #   sSelectText = oTextEditor.getText()
        # console.log sSelectText
      @do_indent(sSelectText, oTextEditor)

  do_indent: (sIndentText, oTextEditor) =>
    eEbinDir = path.join(__dirname, rel_erl_path)
    sIndentText64 = emp.base64_encode(sIndentText)
    # @iTabLen = atom.config.get(emp.EMP_ERL_INDENT_TAB_LEN)
    # @bUseTab = atom.config.get(emp.EMP_ERL_INDENT_USE_TAB)
    console.log @iTabLen, @bUseTab

    sErlCom = 'erl -pa ' + eEbinDir + ' -select_text '+ "\"#{sIndentText64}\""
    sErlCom = sErlCom + ' -tab_length' + " #{@iTabLen}"
    sErlCom = sErlCom + ' -use_tab' + " #{@bUseTab}"
    sErlCom = sErlCom + ' -start_point' + " 0"

    oNodeObj = emp.mk_node_name()
    sErlCom = sErlCom+oNodeObj.node_name+' -run erl_indent erl_indent -noshell -s erlang halt'
    console.log sErlCom
    c_process.exec sErlCom, (error, stdout, stderr) =>
      # console.log "compile:#{stdout}"
      if stdout
        # console.log "compile:#{stdout}"
        # oTextEditor.setText("asdasd")
        oTextEditor.setText(stdout)

      if (error instanceof Error)
        console.log error.message
        emp.show_error(error.message)
      if stderr
        console.error "compile:#{stderr}"

  start_erl_node: ->
    eEbinDir = path.join(__dirname, rel_erl_path)

    oNodeObj = emp.mk_node_name()


    # console.log sErlCom
    if @node_pid
      tmp_pid = @node_pid
      @node_pid = null
      tmp_pid.kill()
    # node_pid = c_process.exec sErlCom, (error, stdout, stderr) =>
    #   # console.log "compile:#{stdout}"
    #   if stdout
    #     # console.log "compile:#{stdout}"
    #     # oTextEditor.setText("asdasd")
    #     oTextEditor.setText(stdout)
    #
    #   if (error instanceof Error)
    #     console.log error.message
    #     emp.show_error(error.message)
    #   if stderr
    #     console.error "compile:#{stderr}"
    # console.log sErlCom
    aParamArray = ['-pa ', eEbinDir, " -sname ", oNodeObj.name, ' -noshell ']
    # console.log aParamArray
    sIndentText = ""
    bIndentFlag = false
    iStartFlag=0
    iEndFlag = 0
    try
      @node_pid = c_process.spawn 'erl', aParamArray,  {cwd:eEbinDir, env: process.env}

      @node_pid.stdout.on 'data', (data) =>
        aResult = data.binarySlice()
        console.log aResult.length
        # console.log aResult
        # console.log typeof(aResult)
        # console.log @indent_editor
        if bIndentFlag

          iEndFlag = aResult.substr aResult.length-iFlagLen
          # console.log iStartFlag
          console.log iEndFlag

          # console.log iStartFlag

          # console.log sText
          # console.log @indent_editor[iStartFlag]

          if oTextEditor = @indent_editor[iEndFlag]
            bIndentFlag = false
            sText = aResult.slice iFlagLen, aResult.length-iFlagLen
            sIndentText = sIndentText+sText
            oTextEditor.setText sIndentText
          else
            sIndentText = sIndentText+aResult
        else
          iRLen = aResult.length
          iStartFlag = aResult.substr 0,iFlagLen
          iEndFlag = aResult.substr iRLen-iFlagLen
          console.log iStartFlag, iEndFlag
          sText = aResult.slice iFlagLen, iRLen-iFlagLen
          unless !oTextEditor = @indent_editor[iStartFlag]
            bIndentFlag = true
            if iStartFlag is iEndFlag
              oTextEditor.setText sText
            else
              sIndentText = sText
        # console.info data.binarySlice()
      # pid.stdout.pipe process.stdout

      @node_pid.stderr.on 'data', (data) ->
        console.error data.binarySlice()

      @node_pid.on 'SIGINT', (data) ->
        console.log "-------------------------"
        console.log data

      @node_pid.on 'error', (err) ->
        console.log "Failed to start child process."
        console.log err

      @node_pid.on 'close', (code) ->
        # app_state = false
        # pid.stdin.write('q().\r\n')
        # set_app_stat(false)
        unless !@node_pid
          @node_pid.stdin.end()

        @node_pid=null
        # emp_app_view.refresh_app_st(app_state)
        console.warn "close over:#{code}"

    catch error
      console.log error
      tmp_pid = @node_pid
      @node_pid = null
      tmp_pid.kill()


  send_indent_msg: ->
    # console.log @node_pid
    unless @node_pid
      @start_erl_node()

    oTextEditor = atom.workspace.getActiveTextEditor()
    unless oTextEditor
      return

    sFilePath = oTextEditor.getPath()
    sFileExt = path.extname(sFilePath ).toLowerCase() unless !sFilePath
    # console.log sFileExt
    unless sFileExt isnt emp.DEFAULT_EXT_ERL
      sSelectText = oTextEditor.getText()
      if oTextEditor.getSelectedText()
        console.log "---------- select text ------------"
        oBufferRange = oTextEditor.getSelectedBufferRanges()
        console.log oBufferRange

      # eEbinDir = path.join(__dirname, rel_erl_path)
      sIndentText64 = emp.base64_encode(sSelectText)
      # iTabLen = atom.config.get(emp.EMP_ERL_INDENT_TAB_LEN)
      # bUseTab = atom.config.get(emp.EMP_ERL_INDENT_USE_TAB)
      # console.log iTabLen, bUseTab
      # console.log "do ----------"
      # console.log "\"#{sSelectText}\""
      iRandFlag = @do_store_editor(oTextEditor)

      @do_send( "erl_indent:erl_indent(#{@iTabLen}, #{@bUseTab}, 0, \"#{iRandFlag}\", \"#{sIndentText64}\").\n")
    #
    # sErlCom = 'erl -pa ' + eEbinDir + ' -select_text '+ "\"#{sIndentText64}\""
    # sErlCom = sErlCom + ' -tab_length' + " #{iTabLen}"
    # sErlCom = sErlCom + ' -use_tab' + " #{bUseTab}"
    # sErlCom = sErlCom + ' -start_point' + " 0"

  do_store_editor: (oEditor)->
    iRandFlag = ""+emp.mk_rand(iFlagLen)
    if @indent_editor[iRandFlag]
      @do_store_editor(oEditor)
    else
      @indent_editor[iRandFlag] = oEditor
      return iRandFlag


  do_send: (str)->
    # console.log "do_else"
    # console.log str
    @node_pid.stdin.write(str)
    # @node_pid.stdin.write('io:format("test ~n",[]). \n')
