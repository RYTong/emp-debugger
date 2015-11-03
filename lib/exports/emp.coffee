# macro defined
fs = require 'fs'
path = require 'path'
os = require 'os'
remote = require 'remote'
dialog = remote.require 'dialog'

module.exports =
  parser_beam_file_mod : 'atom_pl_parse_json'

  EMP_APP_EXPORT_UI_PATH :'emp-template-management.Store-UI-Snippet-Export-Path'
  EMP_APP_IMPORT_UI_PATH :'emp-template-management.Store-UI-Snippet-Import-Path'
  EMP_APP_STORE_UI_PATH :'emp-template-management.Store-UI-Snippet-Path'

  EMP_APP_WIZARD_APP_P :'emp-debugger.Default-App-Wizard-App-Path'
  EMP_APP_WIZARD_EWP_P :'emp-debugger.Default-App-Wizard-Ewp-Path'
  EMP_TEMP_WIZARD_NAME :'emp-debugger.Default-Template-App-Name'
  EMP_TEMP_WIZARD_PATH :'emp-debugger.Default-Template-App-Path'
  EMP_TEMP_WIZARD_PORT :'emp-debugger.Default-Template-App-Port'
  EMP_TEMP_WIZARD_APORT :'emp-debugger.Default-Template-App-APort'
  EMP_LINK_UNIGNORE_CONF :'emp-debugger.EMP-Link-Unignore'
  EMP_LOG_LINE_LIMIT :'emp-debugger.defLimitOfLogLine'
  EMP_LOG_LINE_LIMIT_SELECTED :'emp-debugger.defLimitOfLogLineSelected'
  EMP_DEF_LINE_LIMIT_SELECTED : 1000

  EMP_DEF_LOG_LINE_LIMIT:[500, 1000, 2000, 5000, 10000]

  EMP_DEF_LOG_TYPE:"lua"

  EMP_NODE_NAME :'emp-debugger.Default-EMP-NODE-NAME'
  EMP_NODE_COOKIE :'emp-debugger.Default-EMP-NODE-COOKIE'
  EMP_NODE_NAME : 'ebank@localhost'
  EMP_NODE_COOKIE : 'ewpcool'

  bash_path_key:'emp-debugger.path'

  EMP_MAKE_CMD_KEY: 'emp-debugger.emp-make'
  EMP_STAET_SCRIPT_KEY: 'emp-debugger.emp-start-script'
  EMP_STAET_FRONT_SCRIPT_KEY: 'emp-debugger.emp-start-front-script'
  EMP_CONFIG_KEY: 'emp-debugger.emp-config'
  EMP_CONFIG_ARG_KEY: 'emp-debugger.emp-config-arg'
  EMP_IMPORT_MENU_KEY : 'emp-debugger.emp-import-menu'
  EMP_TMPORARY_APP_NAME:'emp-debugger.emp-tmp-app-name'
  EMP_CMAKE_KEY : 'emp-debugger.emp-c_app'

  EMP_OFFLINE_DIR: 'emp-debugger.emp-offline-dev-path'
  EMP_OFFLINE_RELATE_DIR: 'emp-debugger.emp-offline-relate-path'
  EMP_OFFLINE_RELATE_PATH_V: "public/www/resource_dev"
  EMP_VIEW_FILTER_IGNORE:["*.json", "*.lua", "*.png", "*.jpg", "*.css", "*.js"]
  EMP_SCRIPT_FILTER_IGNORE:["*.json", "*.xhtml", "*.png", "*.jpg", "*.css"]


  EMP_CHANNEL_ADAPTER_PLAT:'emp-debugger.emp-channel-adapter-platform'
  EMP_CHANNEL_ADAPTER_RES:'emp-debugger.emp-channel-adapter-resolution'

  OS_DARWIN:'darwin'
  OS_LINUX:'linux'
  OS_PATH:'PATH'
  COL_KEY:"collections"
  CHA_KEY:"channels"

  # front template macro
  DEF_APP_FILE:'.app'
  DEF_PORT_FILE:'.port'
  DEF_APORT_FILE:'.aport'


  COL_ROOT_TYPE:1
  COL_CH_TYPE:0
  ITEM_CHA_TYPE:1
  ITEM_COL_TYPE:0
  # channel 回调类型
  CHANNEL_ADAPTER:'channel_adapter'
  CHANNEL_NEW_CALLBACK: 'new_callback'
  CHANNEL_CALLBACK: 'channel_callback'
  CHANNEL_PROXY: 'channel_proxy'
  EMP_CHANNEL_URI : 'emp://wizard'
  EMP_APP_URI : 'emp://app_wizard'
  EMP_TEMP_URI : 'emp://template_wizard'
  EMP_FRONT_PAGE_URI : 'emp://front_page_wizard'

  CHA_WIZARD_VIEW: 'EmpView'
  APP_WIZARD_VIEW: 'EmpAppView'
  TEMP_WIZARD_VIEW: 'EmpTemplateView'
  FRONT_PAGE_WIZARD_VIEW: 'EmpFrontPageView'

  CHA_CODE_DIR:'src'
  CHA_PUBLIC_DIR:'public'
  CHA_FRONT_MENU_DIR:'public/menu'
  CHA_FRONT_VITUAL_COL:'virtual_collection'

  # channel adapter 代码生成过程中的取值类型，
  # 分别为 params， arg， session
  ADAPTER_ARG_M_P:'param'
  ADAPTER_ARG_M_A:'arg'
  ADAPTER_ARG_M_S:'session'

  # 离线资源平台
  ADAPTER_PLT_D: 'common'
  ADAPTER_PLT_I: 'iphone'
  ADAPTER_PLT_A: 'android'
  ADAPTER_PLT_W: 'wphone'

  # 离线资源分辨率
  ADAPTER_PLT_R: 'default'
  ADAPTER_PLT_R1: '320-480'
  ADAPTER_PLT_R2: '640-960'
  ADAPTER_PLT_R3: '640-1136'
  ADAPTER_PLT_R4: '750-1334'
  ADAPTER_PLT_R5: '768-1024'
  ADAPTER_PLT_R6: '1080-1920'
  ADAPTER_PLT_R7: '1536-2048'

  # 普通离线资源包，头名称
  ADAPTER_PACKAGE_HEAD: 'package'
  ADAPTER_UNION_PACKAGE_CHEAD:"batch-normal__"
  ADAPTER_UNION_PACKAGE_NAME: "batch-normal-package.zip"
  DEFAULT_ZIP_FULE_NAME:"default.zip"

  # channel 插件包相关定义
  PACKAGE_EXTENSION_BEAM:".beam"
  PACKAGE_EXTENSION_BEAM_TYPE:"beam"
  PACKAGE_CHANNEL_EBIN_DIR: "ebin"
  PACKAGE_CHANNEL_CS_DIR: "public/cs/channels"
  PACKAGE_NORMAL_CHANNEL:"normal_channel"
  PACKAGE_SPEC:"SPEC"
  PACKAGE_CHECKSUM:"CHECKSUM"

  # channel 管理页面分页名称
  GEN_VIEW:'gen_view'
  ADD_CHA_VIEW:'add_cha_view'
  ADD_COL_VIEW:'add_col_view'


  ATOM_CONF_CHANNEL_DIR_KEY:'emp-debugger.Channel-config-file'
  ATOM_CONF_CHANNEL_DIR_DEFAULT:'/config/channel.conf'
  ATOM_EMP_APGE_ENTRANCE:'/public/www/entrance.xhtml'
  EMP_ENTRANCE_FIRST_ID: '${first_cha_id}'
  EMP_ENTRANCE_FIRST_TRANCODE: '${first_tran_code}'

  # EMP_ENTRANCE_NEXT_ID: '${next_cha_id}'
  EMP_ENTRANCE_NEXT_TRANCODE: '${next_tran_code}'

  # adapter template
  STATIC_TEMPLATE_DIR:"/templates/"
  STATIC_APP_TEMPLATE:"/templates/app/"
  STATIC_DEF_APP_TEMPLATE:"/templates/app/5.3"
  STATIC_CHANNEL_TEMPLATE:"/templates/channel/"
  CHANNEL_ADAPTER_DIR:'adapter'
  CHANNEL_NEW_CALLBACK_DIR: 'new_callback'
  CHANNEL_CALLBACK_DIR: 'callback'
  # STATIC_UI_CSS_TEMPLATE_PATH:"/templates/css/"
  STATIC_UI_CSS_TEMPLATE:"/templates/css/eui.css"
  STATIC_UI_CSS_TEMPLATE_DEST_PATH:"public/www/resource_dev/common/css/eui.css"
  STATIC_UI_CSS_TEMPLATE_DEST_DIR:"public/www/resource_dev/common/css/"
  STATIC_UI_CSS_DEF_FILE:"eui.css"
  STATIC_UI_LUA_TEMPLATE:"/templates/lua/ert.lua"
  STATIC_UI_LUA_TEMPLATE_DEST_PATH:"public/www/resource_dev/common/lua/ert.lua"
  STATIC_UI_JS_TEMPLATE:"/templates/js/"
  STATIC_UI_JS_TEMPLATE_DEST_PATH:"public/www/resource_dev/common/js/"
  STATIC_MOB_HTML_PATH:"/templates/mobile/"
  STATIC_MOB_HTML_TEMPLATE:"/templates/mobile/html/default.html"


  STATIC_ERL_TEMPLATE : "/channel_adapter_erl_template.tmp"
  STATIC_ERL_FUN_TEMPLATE : "/channel_adapter_erl_function.tmp"
  STATIC_CS_TEMPLATE : "/channel_adapter_cs_template.tmp"
  STATIC_OFF_TEMPLATE : "/channel_adapter_xHtml_template.tmp"
  STATIC_CSS_TEMPLATE : "/channel_adapter_css_template.tmp"
  STATIC_LUA_TEMPLATE : "/channel_adapter_lua_template.tmp"

  STATIC_WEBVIEW_TEMPLATE : "/channel_webview_template.tmp"

  STATIC_APP_FRONT_TEMP:"/templates/temp_app/"

  COMMON_DIR_LIST :["images", "css", "lua", "xhtml","channels"]
  OFF_CHA_DIR_LIST : ["xhtml", "css", "lua", "images", "json"]
  OFF_CHA_PLT_LIST:["wp", "iphone", "android", "common"]
  OFF_BASE_DIR_LIST:["default"]
  OFF_DEFAULT_BASE:"channels"
  OFF_COMMON_BASE:"default"
  OFF_COMMON_HTML: "webview"
  OFF_WEBVIEW_DEF_APP: "app"
  OFF_STORE_HTML_PATH: "module"
  OFF_HTML_LIST:["js", "css", "images", "html", "module", "fonts", "jsMobile"]
  OFF_HTML_CHI_DIR_LIST : ["html", "css", "js", "json"]

  OFF_EXTENSION_ERL: "erl"
  OFF_EXTENSION_CS: "cs"
  OFF_EXTENSION_JSON: "json"
  OFF_EXTENSION_XHTML:"xhtml"
  OFF_EXTENSION_LUA:"lua"
  OFF_EXTENSION_CSS: "css"
  OFF_EXTENSION_JS: "js"
  OFF_EXTENSION_HTML:"html"

  # the type of emp step
  EMP_ADD_CHA_VIEW_TYPE_EMP: 'emp'
  EMP_ADD_CHA_VIEW_TYPE_HTML: 'html'


  DEFAULT_COL_ITEM:'[{item_id,"$cha_id"},{item_type,$itype},{menu_order,$order}]'

  DEFAULT_CHA_TMP:'\n{channels,[[{id,\"${channel}\"},\r\n'+
                  '            {app,\"${app}\"},\r\n'+
                  '            {name,"${name}"},\r\n'+
                  '            {entry,channel_adapter},\r\n'+
                  '            {views, ${views}},\r\n'+
                  '            {props,${props}},\r\n'+
                  '            {state,${state}}]'

  ADAPTER_REQUEST_PARAMS_FORMAT:"                                      {'$key', $value}"
  ADAPTER_VARIABLE : "    $var = $getter(\"$key\", []),\r\n"
  REPLACE_GETTER : "\\$getter"
  ADAPTER_REQUEST_PARAMS: "{'$key', $value}"
  DEFAULT_EXT_LUA : '.lua'
  DEFAULT_EXT_CSS : '.css'
  DEFAULT_EXT_XHTML :'.xhtml'
  DEFAULT_EXT_JS :'.js'

  DEFAULT_TEMP_HEADER:'<!--<atom_emp_related_file_info>${atom_related_info}</atom_emp_related_file_info>-->\n'
  DEFAULT_LUATEMP_HEADER:'--<atom_emp_related_file_info>${atom_related_info}</atom_emp_related_file_info>--\n'
  DEFAULT_CSSTEMP_HEADER:'/*<atom_emp_related_file_info>${atom_related_info}</atom_emp_related_file_info>*/\n'
  DEFAULT_HEADER:'<atom_emp_related_file_info>${atom_related_info}</atom_emp_related_file_info>\n'
  DEFAULT_HEADER_CON:'<atom_emp_related_file_info>${atom_related_info}</atom_emp_related_file_info>'

  # 提示信息
  EMP_PACKAGE_UNION_PKG_SUCCESS:"普通资源整合包，打包成功~"
  EMP_PACKAGE_PKG_SUCCESS:"普通资源包，打包成功~"
  EMP_PACKAGE_UNION_PKG_DIR_ENOENT:"打包失败：没有离线资源相关文件~"

  EMP_DEFAULT_FRONT_MSG:"{\r\n    \"return\": {\r\n        \"error_code\": \"000000\",\r\n        \"error_msg\": \"\",\r\n
        \"message\": \"This is a msg~~~~~\" \r\n   }\r\n}"


  TEMP_PACKAGE_NAME:"emp-template-management"
  PACKAGE_NAME:"emp-debugger"

  OFF_LINE_LINK_DIR:"public/www/resource_dev/"

  LINK_PUBLICK_DIR:["public/www", "public/www/resource_dev/common/channels","public/www/resource_dev/common/css","public/www/resource_dev/common/lua", "public/www/resource_dev/common/images"]

  get_pack_path: () ->
    atom.packages.resolvePackagePath(this.PACKAGE_NAME)

  get_temp_path: () ->
    atom.packages.resolvePackagePath(this.TEMP_PACKAGE_NAME)

  get_temp_emp_path: ->
    pack_path = atom.packages.resolvePackagePath(this.TEMP_PACKAGE_NAME)
    if pack_path
      path.join(pack_path, "lib/exports/emp")
    else
      null

  create_editor:(tmp_file_path, tmp_grammar, callback, content) ->
    changeFocus = true
    tmp_editor = atom.workspace.open(tmp_file_path, { changeFocus }).then (tmp_editor) =>
      gramers = @getGrammars()
      # console.log content
      unless content is undefined
        tmp_editor.setText(content) #unless !content
      tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined
      callback(tmp_editor)

  # set the opened editor grammar, default is HTML
  getGrammars: (grammar_name)->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      (grammar isnt atom.grammars.nullGrammar) and
      grammar.name is 'CoffeeScript'
    grammars


  get_project_path: ->
    project_path_list = atom.project.getPaths()
    project_path = project_path_list[0]
    editor = atom.workspace.getActiveTextEditor()
    if editor
      # 判断 project 有多个的情况
      efile_path = editor.getPath?()
      if project_path_list.length > 1
        for tmp_path in project_path_list
          relate_path = path.relative tmp_path, efile_path
          if relate_path.match(/^\.\..*/ig) isnt null
            project_path = tmp_path
            break
    project_path



module.exports.mk_node_name = (node_name="") ->
  default_name = " -sname "
  tmp_re = node_name.split("@")
  def_node_name = "atom_js" + Math.round(Math.random()*100)
  def_host = " "
  if tmp_re.length >1
    # console.log "node name has HOST~"
    if valid_ip(tmp_re[1])
      default_name = " -name "
      def_host = get_def_host()
      def_node_name = def_node_name + "@" +def_host
  # console.log def_host
  re_name = default_name + def_node_name
  {name:def_node_name, node_name: re_name}

get_def_host = ->
  add_list = os.networkInterfaces()
  tmp_address = ''
  for key,val of add_list
    # console.log val
    for tmp_obj in val
      if !tmp_obj.internal and tmp_obj.family is 'IPv4'
        tmp_address = tmp_obj.address
        break

  tmp_address


module.exports.show_error = (err_msg) ->
  atom.confirm
    message:"Error"
    detailedMessage:err_msg
    buttons:["Ok"]

module.exports.show_warnning = (warn_msg) ->
  atom.confirm
    message:"Warnning"
    detailedMessage:warn_msg
    buttons:["Ok"]

module.exports.show_info = (info_msg) ->
  atom.confirm
    message:"Info"
    detailedMessage:info_msg
    buttons:["Ok"]

module.exports.self_info = (title_msg, detail_msg) ->
  atom.confirm
    message:title_msg
    detailedMessage:detail_msg
    buttons:["Ok"]


module.exports.isEmpty = (obj) ->
    for key,name of obj
        false;
    true;

module.exports.get_emp_os = () ->
  if !atom.project.emp_os
    atom.project.emp_os = os.platform().toLowerCase()
  atom.project.emp_os


module.exports.mkdir_sync = (tmp_dir) ->
  if !fs.existsSync(tmp_dir)
    fs.mkdirSync(tmp_dir);

module.exports.mkdirs_sync = (root_dir, dir_list) ->
  for dir in dir_list
    tmp_dir = root_dir+dir
    if !fs.existsSync(tmp_dir)
      fs.mkdirSync(tmp_dir);

module.exports.mkdir_sync_safe = (tmp_dir) ->
   if !fs.existsSync(tmp_dir)
     this.mkdir_sync_safe(path.dirname tmp_dir)
     fs.mkdirSync(tmp_dir);

module.exports.base64_encode = (data) ->
  new Buffer(data).toString('base64')

module.exports.base64_decode = (data) ->
  new Buffer(data, 'base64').toString()

mk_dirs_sync = (p, made) ->
  # default mode is 0777

  # mask = ~process.umask()
  #
  # mode = 0777 & (~process.umask()) unless mode
  made = null unless made
  # mode = parseInt(mode, 8) unless typeof mode isnt 'string'
  p = path.resolve(p)
  try
      fs.mkdirSync(p)
      made = made || p
  catch err0
    switch err0.code
        when 'ENOENT'
          made = mk_dirs_sync(path.dirname(p), made)
          mk_dirs_sync(p, made)

        # // In the case of any other error, just see if there's a dir
        # // there already.  If so, then hooray!  If not, then something
        # // is borked.
        else
          stat = null
          try
              stat = fs.statSync(p)
          catch err1
              throw err0
          unless stat.isDirectory()
            throw err0
  made

# 选择路径
module.exports.chose_path_f = (callback)->
  @chose_path(['openFile'], '', callback)

module.exports.chose_path_d = (callback)->
  @chose_path(['openFile', 'openDirectory'], '', callback)

module.exports.chose_path = (opts=['openFile', "openDirectory"], def_path, callback)->
  dialog.showOpenDialog title: 'Select', defaultPath:def_path, properties: opts, (cho_path) =>
    if cho_path
      if callback
        callback(cho_path[0])

valid_ip = (ip_add)->
    # console.log ip_add
    ip_add.match(///^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$///ig)

module.exports.mk_dirs_sync = mk_dirs_sync
module.exports.valid_ip = valid_ip
