# macro defined
fs = require 'fs'
path = require 'path'
os = require 'os'

module.exports =
  parser_beam_file_mod : 'atom_pl_parse_json'

  EMP_APP_WIZARD_APP_P :'emp-debugger.Default-App-Wizard-App-Path'
  EMP_APP_WIZARD_EWP_P :'emp-debugger.Default-App-Wizard-Ewp-Path'

  EMP_NODE_NAME :'emp-debugger.Default-EMP-NODE-NAME'
  EMP_NODE_COOKIE :'emp-debugger.Default-EMP-NODE-COOKIE'
  EMP_NODE_NAME : 'ebank@localhost'
  EMP_NODE_COOKIE : 'ewpcool'

  bash_path_key:'emp-debugger.path'

  EMP_MAKE_CMD_KEY: 'emp-debugger.emp-make'
  EMP_STAET_SCRIPT_KEY: 'emp-debugger.emp-start-script'
  EMP_CONFIG_KEY: 'emp-debugger.emp-config'
  EMP_CONFIG_ARG_KEY: 'emp-debugger.emp-config-arg'
  EMP_IMPORT_MENU_KEY : 'emp-debugger.emp-import-menu'
  EMP_TMPORARY_APP_NAME:'emp-debugger.emp-tmp-app-name'
  EMP_CMAKE_KEY : 'emp-debugger.emp-c_app'

  OS_DARWIN:'darwin'
  OS_LINUX:'linux'
  OS_PATH:'PATH'
  COL_KEY:"collections"
  CHA_KEY:"channels"


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

  CHA_WIZARD_VIEW: 'EmpView'
  APP_WIZARD_VIEW: 'EmpAppView'

  CHA_CODE_DIR:'src'
  CHA_PUBLIC_DIR:'public'

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


  GEN_VIEW:'gen_view'
  ADD_CHA_VIEW:'add_cha_view'
  ADD_COL_VIEW:'add_col_view'


  ATOM_CONF_CHANNEL_DIR_KEY:'emp-debugger.Channel-config-file'
  ATOM_CONF_CHANNEL_DIR_DEFAULT:'/config/channel.conf'
  ATOM_EMP_APGE_ENTRANCE:'/public/www/entrance.xhtml'
  EMP_ENTRANCE_FIRST_ID: '${first_cha_id}'
  EMP_ENTRANCE_FIRST_TRANCODE: '${first_tran_code}'

  # adapter template
  STATIC_TEMPLATE_DIR:"/templates/"
  STATIC_APP_TEMPLATE:"/templates/app/"
  STATIC_DEF_APP_TEMPLATE:"/templates/app/5.3"
  STATIC_CHANNEL_TEMPLATE:"/templates/channel/"
  CHANNEL_ADAPTER_DIR:'adapter'
  CHANNEL_NEW_CALLBACK_DIR: 'new_callback'
  CHANNEL_CALLBACK_DIR: 'callback'
  STATIC_ERL_TEMPLATE : "/channel_adapter_erl_template.tmp"
  STATIC_ERL_FUN_TEMPLATE : "/channel_adapter_erl_function.tmp"
  STATIC_CS_TEMPLATE : "/channel_adapter_cs_template.tmp"
  STATIC_OFF_TEMPLATE : "/channel_adapter_xHtml_template.tmp"

  COMMON_DIR_LIST :["images", "css", "lua", "xhtml","channels"]
  OFF_CHA_DIR_LIST : ["xhtml", "css", "lua", "images", "json"]
  OFF_CHA_PLT_LIST:["wp", "iphone", "android", "common"]
  OFF_BASE_DIR_LIST:["default"]
  OFF_DEFAULT_BASE:"channels"
  OFF_COMMON_BASE:"default"

  OFF_EXTENSION_ERL: "erl";
  OFF_EXTENSION_CS: "cs";
  OFF_EXTENSION_JSON: "json";
  OFF_EXTENSION_XHTML:"xhtml";

  DEFAULT_COL_ITEM:'[{item_id,"$cha_id"},{item_type,$itype},{menu_order,$order}]'

  DEFAULT_CHA_TMP:'\n{channels,[[{id,\"${channel}\"},\r\n'+
                  '            {app,\"${app}\"},\r\n'+
                  '            {name,"${name}"},\r\n'+
                  '            {entry,channel_adapter},\r\n'+
                  '            {views, ${views}},\r\n'+
                  '            {props,${props}},\r\n'+
                  '            {state,${state}}]'

  ADAPTER_REQUEST_PARAMS_FORMAT:"                                      {'$key', $value}";
  ADAPTER_VARIABLE : "    $var = $getter(\"$key\", []),\r\n";
  REPLACE_GETTER : "\\$getter";
  ADAPTER_REQUEST_PARAMS: "{'$key', $value}";

module.exports.mk_node_name = (node_name) ->
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

valid_ip = (ip_add)->
    # console.log ip_add
    ip_add.match(///^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$///ig)

module.exports.mk_dirs_sync = mk_dirs_sync
module.exports.valid_ip = valid_ip
