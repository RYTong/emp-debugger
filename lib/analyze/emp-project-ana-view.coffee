{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
c_process = require 'child_process'
fs = require 'fs'
fs_plus = require 'fs-plus'
path = require 'path'
# c_process = require 'child_process'
emp = require '../exports/emp'
path_fliter = require '../util/path-loader'
_ = require 'underscore-plus'


# VerifyProjectView = require './emp_verify_project_view'

module.exports =
class EmpAnalyzeView extends View

  @content: ->
    @div class: 'emp-setting-row-snip', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "工程文件分析"

      @div outlet:"emp_log_pane", class: "emp-setting-con panel-body padded", =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", " EMP project analyzing."
          # @subview 'outEditor', new TextEditorView(mini: true, placeholderText: 'Out File Path')
          # @subview 'outEditor2', new TextEditorView(mini: true, placeholderText: 'Out File Path')

        @div class: "emp-set-div-content", =>
          # @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_test', "Test"
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_ana', "Do Ana"
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_ana_cbb', "Ana Cbb"
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_ana_cmm', "Ana CMM"
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_ana_lua', "Ana Lua"

  initialize: ->
    this
    # @outEditor.on 'blur', =>
    #   console.log @outEditor.hasFocus()
    #   console.log @outEditor2.hasFocus()
    #   console.log "on blur"
    #
    # @outEditor2.on 'blur', =>
    #   console.log @outEditor.hasFocus()
    #   console.log @outEditor2.hasFocus()
    #   console.log "on blur"

  aAllFileList = ["*.erl", "*.xhtml", "*.lua", "*.css"]
  aFileList = ["*.xhtml"]
  aLuaList = ["*.lua","*.xhtml"]

  aPureLuaList = ["*.lua"]

  do_test: ->
    console.log @outEditor
    # console.log @outEditor.getModel()

  do_ana_lua: ->
    sProjectPath = emp.get_project_path()
    sProjectPath = path.join sProjectPath,"public/www/resource_dev"
    console.log sProjectPath
    @aPLuaAnaList = {}
    _.map aPureLuaList, (sFileName) =>
      console.log sFileName
      @aPLuaAnaList[sFileName] = @ana_obj(sFileName)

    path_fliter.load_file_path_unignore sProjectPath, aPureLuaList, (@aPLuaPathList) =>
      _.map @aPLuaPathList, (oFileObj) =>
        sFileDir = oFileObj.dir
        sFileExt = '*' + path.extname sFileDir
        if oTmpObj = @aPLuaAnaList[sFileExt]

          oTmpObj.file_num += 1
          oTmpObj.file_list.push sFileDir

      for sKey, oObj of @aPLuaAnaList
        console.log sKey, oObj, oObj.file_list.length
        aPureLuaList = oObj.file_list
        sAllFileCon=""

        _.map aPureLuaList, (sFileName) ->
          # sFileName = path.join sSrcDir,sFileName
          sAllFileCon +=fs.readFileSync sFileName, 'utf-8'

        iAllCoun = sAllFileCon.length
        console.log "AllChar Count: #{iAllCoun}"

        sAllFileCon = sAllFileCon.replace /\ /ig, ""
        iSpaceCount = sAllFileCon.length
        fSpacePer = iSpaceCount/iAllCoun
        console.log "remove space: #{iSpaceCount}, per: #{fSpacePer} , re:#{iAllCoun-iSpaceCount}, reper:#{1-fSpacePer}"


        aFileCon = sAllFileCon.split /[\r\n]/ig
        aRe = _.filter aFileCon, (sStr) ->
                !sStr.match(/\-\-/ig)
        aRe = _.filter aRe, (sStr) ->
          sStr isnt ''
        iReCon = aRe.join("").length
        fRePer = iReCon/iAllCoun
        console.log "comment: #{iReCon}, per: #{fRePer} , release: #{iSpaceCount-iReCon}, reper: #{fSpacePer-fRePer}"
        # console.log iReCon, fRePer, iSpaceCount-iReCon,fSpacePer-fRePer

        # sAllFileCon = aRe.join("")
        # aSlt2Arr = sAllFileCon.match /\#[^\#]*\#/ig
        #
        # sSlt2Str = aSlt2Arr.join("")
        # iSlt2StrLen = aSlt2Arr.length
        #
        # fSlt2Per = iSlt2StrLen/iAllCoun
        # console.log "slt2: #{iSlt2StrLen}, per: #{fSlt2Per} , release: #{iReCon-iSlt2StrLen}, reper: #{fRePer-fSlt2Per}"
        # # console.log iSlt2StrLen, fSlt2Per, iReCon-iSlt2StrLen,fRePer-fSlt2Per




  do_ana_cmm: ->
    sProjectPath = emp.get_project_path()
    sProjectPath = path.join sProjectPath,"public/www/resource_dev"
    console.log sProjectPath
    @aLuaAnaList = {}
    _.map aLuaList, (sFileName) =>
      console.log sFileName
      @aLuaAnaList[sFileName] = @ana_obj(sFileName)
      console.log sProjectPath

    mDivMap = {}
    path_fliter.load_file_path_unignore sProjectPath, ["*.div"], (aDivFileList) =>
      console.log aDivFileList

      _.map aDivFileList, (oFileObj) =>
        mDivMap[oFileObj.name] = @div_file_obj(oFileObj)

      mDivMap["multifunctional_alert"] = mDivMap["multifunctional_alert.div"]
      mDivMap["send_msg"] = mDivMap["T_password.div"]
      mDivMap["include_header_com"] = mDivMap["P_header_com.div"]
      mDivMap["include_header_nomore"] = mDivMap["P_header_nomore.div"]
      mDivMap["include_header_show"] = mDivMap["P_header_show.div"]
      mDivMap["include_header_result"] = mDivMap["P_header_result.div"]
      mDivMap["show_relevance"] = mDivMap["P_relevance_show.div"]



    path_fliter.load_file_path_unignore sProjectPath, aLuaList, (@aLuaPathList) =>
      _.map @aLuaPathList, (oFileObj) =>
        sFileDir = oFileObj.dir
        sFileExt = '*' + path.extname sFileDir
        if oTmpObj = @aLuaAnaList[sFileExt]

          oTmpObj.file_num += 1
          oTmpObj.file_list.push sFileDir

      for sKey, oObj of @aLuaAnaList
        # console.log oObj
        console.log sKey, oObj, oObj.file_list.length
        aTmpFileList = oObj.file_list
        sAllFileCon=""

        _.map aTmpFileList, (sFileName) ->
          # sFileName = path.join sSrcDir,sFileName
          sAllFileCon +=fs.readFileSync sFileName, 'utf-8'

        iAllCoun = sAllFileCon.length
        console.log "all char count :#{iAllCoun}"


        sRegExp = "show_relevance|multifunctional_alert|send_msg|include_header_com|include_header_nomore|include_header_show|include_header_result|NCS0003.div|NCS0004.div|NCM0002_1.div|NCM0002_2.div|NCM0011.div|NCM0011_1.div|notice_msg.div|P_header_com.div|P_header_nomore.div|P_header_result.div|P_header_show.div|P_relevance_show.div|T_password.div|TCCHA01.div|ecash_search.div|NFS0003_list.div|NFS0003_search.div|NFS0004_list.div|NFS0005_list.div|NFS0006.div|NFS0007_list.div|NFS0007_search.div|NFS0008_all.div|NFS0009.div|NFS0013_search.div|NFS0019_list.div|NFS0021_search.div|NFS0024.div|NFS0033.div|TFS1A01.div|TFS6A01.div|NFT0001_select.div|NFT0004_div_lbl_01.div|NFT0004_select.div|NFT0A01_select.div|NGOG001_search.div|NGOI001_search.div|character.div|NPB0001_info.div|NPB0001_info_1.div|NST0001_select.div|NST0002_div_lbl_01.div|NST0A01_div.div|NST0A01_div_select.div|long_before.div|recent_two.div|NWM0004_list.div"


        oRegExp = new RegExp(sRegExp, "ig")
        aRe = sAllFileCon.match oRegExp
        # console.log aRe.length
        # console.log mDivMap
        iAllCount = 0
        # console.log aRe
        for sKey, oObj of mDivMap
          # console.log oObj
          aFilterRE = _.filter aRe, (sReEle) ->
                        sReEle is sKey
          iFilterLen = aFilterRE.length
          # console.log iFilterLen

          iAllCount += iFilterLen*oObj.char_num

        console.log "re char account: #{iAllCount}"


  div_file_obj: (oTmpObj)->

    sFileCon = fs.readFileSync oTmpObj.dir, 'utf-8'
    iFileLen = sFileCon.length
    iFileLineLen = sFileCon.split(/\n/ig).length
    {name:oTmpObj.name, file_dir:oTmpObj.dir, line_num:iFileLineLen, char_num:iFileLen}

  do_ana_cbb: ->
    sProjectPath = emp.get_project_path()
    sProjectPath = path.join sProjectPath,"public/www/resource_dev"
    console.log sProjectPath
    @aCBBAnaList = {}
    _.map aFileList, (sFileName) =>
      console.log sFileName
      @aCBBAnaList[sFileName] = @ana_obj(sFileName)

    path_fliter.load_file_path_unignore sProjectPath, aFileList, (@aCBBPathList) =>
      _.map @aCBBPathList, (oFileObj) =>
        sFileDir = oFileObj.dir
        sFileExt = '*' + path.extname sFileDir
        if oTmpObj = @aCBBAnaList[sFileExt]

          oTmpObj.file_num += 1
          oTmpObj.file_list.push sFileDir

      for sKey, oObj of @aCBBAnaList
        console.log sKey, oObj, oObj.file_list.length
        aTmpFileList = oObj.file_list
        sAllFileCon=""

        _.map aTmpFileList, (sFileName) ->
          # sFileName = path.join sSrcDir,sFileName
          sAllFileCon +=fs.readFileSync sFileName, 'utf-8'

        iAllCoun = sAllFileCon.length
        console.log "AllChar Count: #{iAllCoun}"

        sAllFileCon = sAllFileCon.replace /\ /ig, ""
        iSpaceCount = sAllFileCon.length
        fSpacePer = iSpaceCount/iAllCoun
        console.log "remove space: #{iSpaceCount}, per: #{fSpacePer} , re:#{iAllCoun-iSpaceCount}, reper:#{1-fSpacePer}"


        aFileCon = sAllFileCon.split /[\r\n]/ig
        aRe = _.filter aFileCon, (sStr) ->
                !(sStr.match(/^\<\?/ig) or sStr.match(/^\<\!/ig))
        aRe = _.filter aRe, (sStr) ->
          sStr isnt ''
        iReCon = aRe.join("").length
        fRePer = iReCon/iAllCoun
        console.log "comment: #{iReCon}, per: #{fRePer} , release: #{iSpaceCount-iReCon}, reper: #{fSpacePer-fRePer}"
        # console.log iReCon, fRePer, iSpaceCount-iReCon,fSpacePer-fRePer

        sAllFileCon = aRe.join("")
        aSlt2Arr = sAllFileCon.match /\#[^\#]*\#/ig

        sSlt2Str = aSlt2Arr.join("")
        iSlt2StrLen = aSlt2Arr.length

        fSlt2Per = iSlt2StrLen/iAllCoun
        console.log "slt2: #{iSlt2StrLen}, per: #{fSlt2Per} , release: #{iReCon-iSlt2StrLen}, reper: #{fRePer-fSlt2Per}"
        # console.log iSlt2StrLen, fSlt2Per, iReCon-iSlt2StrLen,fRePer-fSlt2Per


        # sAllFileCon = sAllFileCon.replace /\<head[\r\n\S]*head\>/ig, ""
        #
        # iReHeadLen = sAllFileCon.length
        # fReHeadPer = iReHeadLen/iAllCoun
        #
        # console.log iReHeadLen, fReHeadPer, iReCon-iReHeadLen,fRePer-fReHeadPer


        sCssDir = "/work/code/emp/project/ebank-boc/public/www/resource_dev/common/css"
        sCssCon = ""
        aCssFileList = ["ert_ui.css", "ert_ui_cmm_ui.css", "eui.css"]

        _.map aCssFileList, (sFileName) ->
          sFileName = path.join sCssDir,sFileName
          sCssCon += fs.readFileSync sFileName, "utf-8"

        aCssNameList = sCssCon.match /\.[^\s{]*/ig
        aNewCssList = []
        _.map aCssNameList, (sCssName) ->
          unless sCssName is "."
            aNewCssList.push sCssName.replace(/\./ig, "")

        # console.log aNewCssList
        # console.log aNewCssList
        console.log "aNewCssList: #{aNewCssList.length}, aRe: #{aNewCssList.length}"
        # console.log aNewCssList.length, aRe.length

        sRegExp = aNewCssList.join "|"
        oRegExp = new RegExp(sRegExp, "ig")

        # console.log oRegExp
        iCbbLen = 0
        _.map aRe, (sHtmlLine) ->
          if sHtmlLine.match oRegExp
            # console.log sHtmlLine
            iCbbLen += sHtmlLine.length


        console.log iCbbLen

        iCbbLen = iCbbLen*1.1

        fCbbPer = iCbbLen/iAllCoun

        # console.log iCbbLen, fCbbPer, iReCon-iCbbLen,fRePer-fCbbPer
        console.log "icbb: #{iCbbLen}, per: #{fCbbPer} , release: #{iReCon-iCbbLen}, reper: #{fRePer-fCbbPer}"

        # sAllFileCon = sAllFileCon.replace /\#[^\#]*\#/ig, ""


      # console.log @aCBBAnaList, @aCBBAnaList.file_list.length

      # for sKey, oObj of @aCBBAnaList
      #   # console.log oObj
      #   sCommandOpt = oObj.file_list.join ' '
      #   sCommandOpt = "wc -lc " + sCommandOpt
      #   # console.log sKey
      #   c_process.exec sCommandOpt, (error, stdout, stderr) =>
      #     # console.log(stdout);
      #     aResults = stdout.split /[\r\n]/ig
      #     aResults = _.filter aResults, (sStr) ->
      #                 return sStr isnt ""
      #     sResult=aResults.pop()
      #     # console.log sResult
      #     aTotals = sResult.split " "
      #     [sLineNum, sCharNum] = _.filter aTotals, (sStr) ->
      #                 return sStr isnt ""
      #     # console.log sResult.split " "
      #     iLineNum = 0 unless !isNaN(iLineNum = parseInt(sLineNum))
      #
      #     iCharNum = 0 unless !isNaN(iCharNum = parseInt(sCharNum))
      #     #
      #     if sExtCount =aResults.pop()
      #       aExtCount = sExtCount.split " "
      #       sFileDir = aExtCount.pop()
      #       sKey = '*' + path.extname sFileDir
      #       # console.log sFileExt
      #       oObj = @aCBBAnaList[sKey]
      #
      #
      #     # console.log oObj, iLineNum, iCharNum
      #
      #     oObj.line_num += iLineNum
      #     oObj.char_num += iCharNum
      #     console.log "Name: #{sKey}"
      #     console.log "File Count: #{oObj.file_num}"
      #     console.log "Line Number: #{oObj.line_num}"
      #     console.log "Char Num: #{oObj.char_num}"
      #     console.log "---------------------------------------------"

  do_ana: ->
    sProjectPath = emp.get_project_path()
    # sProjectPath = path.join sProjectPath,"public/www/resource_dev"
    # console.log sProjectPath
    @aAnaList = {}
    _.map aAllFileList, (sFileName) =>
      @aAnaList[sFileName] = @ana_obj(sFileName)
    # console.log @aAnaList

    path_fliter.load_file_path_unignore sProjectPath, aAllFileList, (@aPathList) =>
      # console.log @erl_path_list
    # @refresh_dependences_path()
      # console.log  @aPathList
      _.map @aPathList, (oFileObj) =>
        sFileDir = oFileObj.dir
        sFileExt = '*' + path.extname sFileDir
        if oTmpObj = @aAnaList[sFileExt]

          oTmpObj.file_num += 1
          oTmpObj.file_list.push sFileDir

      # exec('wc /path/to/file', function (error, results) {
      #     console.log(results);
      # });
      for sKey, oObj of @aAnaList
        # console.log oObj
        sCommandOpt = oObj.file_list.join ' '
        sCommandOpt = "wc -lc " + sCommandOpt
        # console.log sKey
        c_process.exec sCommandOpt, (error, stdout, stderr) =>
          # console.log(stdout);
          aResults = stdout.split /[\r\n]/ig
          aResults = _.filter aResults, (sStr) ->
                      return sStr isnt ""
          sResult=aResults.pop()
          # console.log sResult
          aTotals = sResult.split " "
          [sLineNum, sCharNum] = _.filter aTotals, (sStr) ->
                      return sStr isnt ""
          # console.log sResult.split " "
          iLineNum = 0 unless !isNaN(iLineNum = parseInt(sLineNum))

          iCharNum = 0 unless !isNaN(iCharNum = parseInt(sCharNum))
          #
          if sExtCount =aResults.pop()
            aExtCount = sExtCount.split " "
            sFileDir = aExtCount.pop()
            sKey = '*' + path.extname sFileDir
            # console.log sFileExt
            oObj = @aAnaList[sKey]


          # console.log oObj, iLineNum, iCharNum

          oObj.line_num += iLineNum
          oObj.char_num += iCharNum
          console.log "Name: #{sKey}"
          console.log "File Count: #{oObj.file_num}"
          console.log "Line Number: #{oObj.line_num}"
          console.log "Char Num: #{oObj.char_num}"
          console.log "---------------------------------------------"
          # # console.log stdout.split " "
          #
          # _.map aResults, (sFileCount) =>
          #   aResult = sFileCount.split " "
          #   [sLineNum, sCharNum] = _.filter aResult, (sStr) ->
          #     return sStr isnt "" and !isNaN(sStr)
          #   # # [sLineNum, sCharNum] = stdout.split " "
          #   # console.log aResult
          #   #
          #   # # console.log sLineNum, sCharNum
          #   iLineNum = 0 unless !isNaN(iLineNum = parseInt(sLineNum))
          #
          #   iCharNum = 0 unless !isNaN(iCharNum = parseInt(sCharNum))
          #   #
          #   console.log sKey, iLineNum, iCharNum
          #   oObj.line_num += iLineNum
          #   oObj.char_num += iCharNum

        # for definition in stdout.trim().split('\n')
        #   [key, value] = definition.split('=', 2)
        #   key = key.trim().split(" ").pop()
        #   # console.log "key:#{key}, value:#{value}"
        #   unless key isnt emp.OS_PATH
        #     process.env[key] = value
        #     atom.config.set(bash_path_key, value)

      console.log @aAnaList





  ana_obj: (tmp_name)->
    {name:tmp_name, file_num:0, file_list:[], line_num:0, char_num:0}



  on_file: (file_path)=>
    # console.log "file"
    # console.log file_path
    # console.log @project_path
    file_ext  = path.extname(file_path?='')?.toLowerCase()
    relative_path = path.relative @project_path, file_path
    # 判断文件类型,目前基本只支持 xhtml 和 lua

    if file_ext is emp.DEFAULT_EXT_XHTML
      replace_con = emp.DEFAULT_TEMP_HEADER
      do_check_file(file_path, relative_path, replace_con)
    else if file_ext is emp.DEFAULT_EXT_LUA
      replace_con = emp.DEFAULT_LUATEMP_HEADER
      do_check_file(file_path, relative_path, replace_con)
    else if file_ext is emp.DEFAULT_EXT_CSS
      replace_con = emp.DEFAULT_CSSTEMP_HEADER
      do_check_file(file_path, relative_path, replace_con)
    true

  on_dir: (param)->
    # console.log "dir"
    # console.log param
    true

  on_done: (param)->
    # console.log "done"
    # console.log param
    emp.show_info "全工程添加文件关联完成."
    true


  add_link: ->
    console.log "add_link"
    editor = atom.workspace.getActiveTextEditor()
    project_path = emp.get_project_path()

    if editor
      text_path = editor.getPath()
      text_ext  = path.extname(text_path?='').toLowerCase()
      relative_path = path.relative project_path, text_path
      # console.log project_path

      replace_con = ''

      editor_text = editor.getText()
      if editor_text.match /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig
        replace_con = emp.DEFAULT_HEADER_CON
        replace_con = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
        editor_text = editor_text.replace /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig, replace_con
        editor.setText editor_text

      else
        # 判断文件类型,目前基本只支持 xhtml 和 lua
        if text_ext is emp.DEFAULT_EXT_XHTML
          replace_con = emp.DEFAULT_TEMP_HEADER

          do_add(replace_con, relative_path, editor)
        else if text_ext is emp.DEFAULT_EXT_LUA
          replace_con = emp.DEFAULT_LUATEMP_HEADER
          do_add(replace_con, relative_path, editor)
        else if text_ext is emp.DEFAULT_EXT_CSS
          replace_con = emp.DEFAULT_CSSTEMP_HEADER
          do_add(replace_con, relative_path, editor)
        else
          replace_con = emp.DEFAULT_HEADER
          @show_alert(replace_con, relative_path, editor)


  # 如果为非 lua 或者 xhtml ,提示是否强制添加
  show_alert: (replace_con, relative_path, editor) ->
    atom.confirm
      message: '文件类型警告!'
      detailedMessage: '判断当前文件类型不是 Xhtml, Lua或者 Css, 该文件关联并不支持该文件类型.是否继续添加?'
      buttons:
        '是': -> do_add(replace_con, relative_path, editor)
        '否': -> return

# 插入代码段到第二行
do_add = (replace_con, relative_path, editor)->
    last_cursor = editor.getLastCursor()
    # cursor_point = last_cursor.getBufferRow()
    # cursor_screeen_point = last_cursor.getScreenRow()
    # editor.moveUp(cursor_screeen_point)
    last_cursor.setBufferPosition([1,0], autoscroll:true)
    last_cursor.setVisible()
    file_header = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
    console.log "insert: #{file_header}"
    editor.insertText file_header, autoIndentNewline:true,select:true

do_check_file = (file_path, relative_path, replace_con) ->
  # console.log "check file"
  temp_con = fs.readFileSync(file_path, 'utf-8')
  if temp_con.match /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig
    replace_con = emp.DEFAULT_HEADER_CON
    replace_con = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
    temp_con = temp_con.replace /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig, replace_con
  else
    file_footer = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
    temp_con = temp_con+file_footer
  fs.writeFileSync file_path, temp_con, 'utf-8'
