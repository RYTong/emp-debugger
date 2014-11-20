emp = require '../../exports/emp'
path = require 'path'
fs = require 'fs'
conf_parser = require '../../emp_app/conf_parser'

module.exports =
class emp_channel
  id:null
  name:null
  app:null
  entry:null
  entry_dir:emp.CHANNEL_ADAPTER_DIR
  state:1

  use_cs:true
  use_off:true
  use_code:true

  off_detail:{}
  adapters:{}
  params:{}


  constructor: ->
    # console.log "this is a channel"
    @adapters = {}
    @params = {'method':'post', 'encrypt':'0'}

  set_id: (@id) ->

  set_state:(tmp_state) ->
    if tmp_state
      @state = 1
    else
      @state = 0

  # @doc 设置channel 的entry 类型，
  # 并设置相关entry 类型的保存路径
  set_entry:(tmp_entry) ->
    if tmp_entry is emp.CHANNEL_ADAPTER
      @entry = emp.CHANNEL_ADAPTER
      @entry_dir = emp.CHANNEL_ADAPTER_DIR
    else
      @entry = emp.CHANNEL_NEW_CALLBACK
      @entry_dir = emp.CHANNEL_NEW_CALLBACK_DIR

  set_off_detail: (off_plat, off_res)->
    @off_detail.plat = off_plat
    @off_detail.res = off_res

  set_off_detailf: (oimg_flag, ocss_flag, olua_flag, oxhtml_flag, ojson_flag) ->
    @off_detail.img = oimg_flag
    @off_detail.css = ocss_flag
    @off_detail.lua = olua_flag
    @off_detail.xhtml = oxhtml_flag
    @off_detail.json = ojson_flag

  initial_adapter: ->
    @adapters={}

  # @doc 保存adapter 的相关参数
  store_adapter: (a_obj) ->
    tmp_tran = a_obj.trancode
    # console.log a_obj
    # console.log "the adapter tran code tmp_tran: #{tmp_tran}"
    if tmp_tran
      if tmp_tran.trim()
        @adapters[tmp_tran] = a_obj

  initial_param: ->
    @params = {}

  get_param: ->
    @params

  # @doc 保存channel 类型中的props 字段
  store_param: (param) ->
    tmp_key = param.key
    tmp_val = param.value
    if !tmp_val
      tmp_val = 'undefined'
    if tmp_key
      @params[tmp_key] = tmp_val

  # 编辑channel
  edit_channel: ->
    # console.log "edit channel"
    if atom.project.emp_app_state
      @format_edit_channel_fun()
    else if atom.project.emp_node_state
      @format_edit_channel_fun('node')
    else
      @format_edit_channel()
    @create_adapter_detail()

  # @doc 拼接参数串，用于传递给erl 处理
  format_edit_channel: ->
    p_str = " -id #{@id} -app #{@app} -name #{@name} -entry #{@entry} "
    p_str = p_str + " -state #{@state}"
    # console.log p_str
    # @doc 拼接 props 的相关字段
    params_str = ""
    for tmp_key,tmp_val of @params
      params_str = params_str + "|#{tmp_key}|#{tmp_val}"
    p_str = p_str + " -props \"#{params_str}\" "

    # @doc 拼接 views 的相关参数字段
    views_str = ""
    for tmp_key,tmp_objs of @adapters
      views_str = views_str + "|#{tmp_key}|#{tmp_objs.view}"
    if views_str is ""
      views_str = 'undefined'
    p_str = p_str + " -views \"#{views_str}\" "
    conf_parser.edit_cha(p_str)

  # @doc 拼接参数串，用于传递给emp app 处理
  format_edit_channel_fun: (type)->
    # console.log "edit channel "
    tmp_conf = atom.project.channel_conf
    # @doc 拼接 props 的相关字段
    params_str = []
    for tmp_key,tmp_val of @params
      params_str.push("{#{tmp_key},#{tmp_val}}")

    if params_str.length is 0
      params_str = 'undefined'
    else
      params_str = "["+params_str.join(",")+"]"

    # @doc 拼接 views 的相关参数字段
    views_str = []
    for tmp_key,tmp_objs of @adapters
      views_str.push("{\"#{tmp_key}\",\"#{tmp_objs.view}\"}")
    if views_str.length is 0
      views_str = 'undefined'
    else
      views_str = "["+views_str.join(",")+"]"
    tmp_pid = null
    if !type
      erl_str = "#{emp.parser_beam_file_mod}:edit_cha(\"#{tmp_conf}\",
                  \"#{@id}\", \"#{@name}\", \"#{@app}\", \"#{@entry}\", #{views_str}, #{params_str}, #{@state})."
      # console.log erl_str
      tmp_pid = atom.project.emp_app_pid
    else
      tmp_node_name = atom.project.emp_node_name
      erl_str = "#{emp.parser_beam_file_mod}:node_fun_call(\'#{tmp_node_name}\', edit_cha, [\"#{tmp_conf}\",
                  \"#{@id}\", \"#{@name}\", \"#{@app}\", \"#{@entry}\", #{views_str}, #{params_str}, #{@state}])."
      # console.log erl_str
      tmp_pid = atom.project.emp_node_pid
    tmp_pid.stdin.write(erl_str+'\r\n')

  # ---------------------------------------------------------------------------
  # 完成创建 channel
  create_channel: (all_cha_len)->
    # console.log "create_channel"
    @format_channel(all_cha_len)
    # 根据channel 的实例类型不同，进行不同的处理
    if @entry is emp.CHANNEL_NEW_CALLBACK
      console.log "create new callback"
    else
      @create_adapter_detail()

    # @refresh_channel_menu()

  # @doc 编译erl 模块
  # recompile_channel_mod: ->
  #   # console.log "refresh mod"
  #   if atom.project.emp_app_state
  #     tmp_pid = atom.project.emp_app_pid
  #     if erl_cstr = atom.config.get(emp.EMP_CMAKE_KEY)
  #       tmp_pid.stdin.write(erl_cstr+'\r\n')

  refresh_channel_menu: ->
    # @doc 添加channel 之后自动同步
    if atom.project.emp_app_state
      tmp_pid = atom.project.emp_app_pid
      if erl_str = atom.config.get(emp.EMP_IMPORT_MENU_KEY)
        tmp_pid.stdin.write(erl_str+'\r\n')

      if erl_cstr = atom.config.get(emp.EMP_CMAKE_KEY)
        tmp_pid.stdin.write(erl_cstr+'\r\n')

    else if atom.project.emp_node_state
      tmp_pid = atom.project.emp_node_pid
      tmp_node_name = atom.project.emp_node_name
      erl_str = "#{emp.parser_beam_file_mod}:node_fun_call(\'#{tmp_node_name}\', node_refresh_cha, [])."
      # console.log erl_str
      tmp_pid.stdin.write(erl_str+'\r\n')


  # 在channel.conf 中添加channel
  format_channel: (all_cha_len)->
    tmp_view = [] #'undefined'
    if @entry is emp.CHANNEL_NEW_CALLBACK
      console.log "no this channel type temporarily~"
    else
      for key,objs of @adapters
        tmp_v = "{\"#{objs.trancode}\", \"#{objs.view}\"}"
        tmp_view.push(tmp_v)

    if tmp_view.length is 0
      tmp_view = 'undefined'
    else
      tmp_view = "[" +tmp_view.join(",")+"]"

    tmp_props = []
    for p_key, p_val of @params
      tmp_p = "{#{p_key}, #{p_val}}"
      tmp_props.push(tmp_p)
    if tmp_props.length is 0
      tmp_props = '[]'
    else
      tmp_props = "[" +tmp_props.join(",")+"]"

    tmp_ch = path.join __dirname, '../../../', emp.STATIC_CHANNEL_TEMPLATE,@entry_dir,'/channel.txt'
    # console.log "channel tm path:#{tmp_ch}"
    f_con = null
    if fs.existsSync(tmp_ch)
      f_con = fs.readFileSync(tmp_ch, 'utf8')
    else
      f_con = emp.DEFAULT_CHA_TMP

    f_con = f_con.replace('${channel}', @id).replace('${name}', @name).replace('${entry}', @entry)
    f_con = f_con.replace(/\$\{views\}/ig, tmp_view).replace(/\$\{app\}/ig, @app)
    f_con = f_con.replace(/\$\{state\}/ig, parseInt(@state)).replace(/\$\{props\}/ig, tmp_props)
    if all_cha_len > 0
      f_con = f_con+',\n'
    # console.log f_con
    cha_con = fs.readFileSync(atom.project.channel_conf, 'utf8')
    cha_con = cha_con.replace(/(%+[^\n]*\n+)*[\s\r\n\t]*\{[\s\r\n\t]*([\s\r\t]*%+[^\n]*\n+)*[\s\r\t]*channels\W*,([\s\r\t]*%+[^\n]*\n+)*[^\[]*\[/ig, f_con)
    fs.writeFileSync(atom.project.channel_conf, cha_con, 'utf8')


  # 为实例类型为adapter 的channel 进行处理
  create_adapter_detail: ->
    try
      project_path = atom.project.getPath()
      if @use_code
        @create_code(project_path)
      # console.log '111'
      if @use_off
        @create_off(project_path)
      # console.log '2222'
      if @use_cs
        @create_cs(project_path)
    catch err
      console.error(err)
      throw("创建辅助代码失败")

  #@doc 创建辅助的erlang代码
  create_code: (project_path)->
    src_dir = path.join project_path,emp.CHA_CODE_DIR
    cha_dir = path.join src_dir, emp.OFF_DEFAULT_BASE
    code_dir = path.join(cha_dir, (@id+"."+emp.OFF_EXTENSION_ERL))
    # console.log "code dir :#{code_dir}"
    emp.mkdir_sync(src_dir)
    emp.mkdir_sync(cha_dir)
    fs.exists code_dir, (exist_stat) =>
      tmp_basic_dir = path.join __dirname, '../../../', emp.STATIC_CHANNEL_TEMPLATE, @entry_dir
      tmp_code_dir = path.join tmp_basic_dir,emp.STATIC_ERL_TEMPLATE
      tmp_fun_dir = path.join tmp_basic_dir,emp.STATIC_ERL_FUN_TEMPLATE
      code_con = ""
      fun_con = ""
      all_fun_con = ""
      # console.log "exist ---- : #{exist_stat}"
      if !exist_stat
        code_con = fs.readFileSync tmp_code_dir, 'utf8'
        code_con = code_con.replace('$module', @id)
        fun_con = fs.readFileSync tmp_fun_dir, 'utf8'
        # console.log @adapters
        for key,obj of @adapters
          tmp_con = fun_con.replace(/\$trancode/ig, obj.trancode)

          if obj.adapter
            param_con = ""
            key_con = ""
            tmp_con = tmp_con.replace(/\$adapter/ig, obj.adapter)
            tmp_con = tmp_con.replace(/\$procedure/ig, obj.procedure)
            key_list = @format_key_list(obj)
            parm_con = key_list[0]
            rkey_con = key_list[1]
            tmp_con = tmp_con.replace(/\$params/ig, parm_con)
            tmp_con = tmp_con.replace(/\$keylist/ig, rkey_con)
            tmp_con = tmp_con.replace(/\$preadapter_region/ig, '')
            tmp_con = tmp_con.replace(/\$noadapter_region[\s\S]*noadapter_region/ig, '')
          else
            tmp_con = tmp_con.replace(/\$params/ig, '')
            tmp_con = tmp_con.replace(/\$noadapter_region/ig, '')
            tmp_con = tmp_con.replace(/\$preadapter_region[\s\S]*preadapter_region/ig, '')
          code_con = code_con+tmp_con
        fs.appendFile code_dir, code_con, 'utf8', (err) =>
          if err
            console.error(err)
            emp.show_error("创建辅助Erl代码失败~")
          # @recompile_channel_mod()
      # else


  #@doc 处理adapter 中配置的参数
  format_key_list: (obj)->
    param_con = ""
    rkey_con = emp.ADAPTER_REQUEST_PARAMS
    rkey_con = rkey_con.replace(/\$key/ig, 'tranCode').replace(/\$value/ig, 'TranCode')

    tmp_p = emp.ADAPTER_REQUEST_PARAMS
    index = 0
    # console.log obj.params
    for p in obj.params
      index += 1
      p_key = p.key
      # console.log "ke:#{p_key} i:#{index}"
      p_name = @format_key(p_key, index)
      # console.log "p_name:#{p_name}"
      r_key = p.rkey
      type = p.type
      tmp_pcon = emp.ADAPTER_VARIABLE.replace(/\$var/ig, p_name)
      tmp_pcon = tmp_pcon.replace(/\$key/ig, p_key).replace(/\$getter/ig, '?'+type)
      param_con = param_con+tmp_pcon

      tmp_rcon = emp.ADAPTER_REQUEST_PARAMS_FORMAT.replace(/\$key/ig, r_key)
      tmp_rcon = tmp_rcon.replace(/\$value/ig, p_name)
      rkey_con = rkey_con + ',\r\n' + tmp_rcon
    [param_con, rkey_con]

  # @doc 创建变量名称，把首字母修改为大写（符合Erlang 变量命名规范）
  format_key: (key,i)->
    (key+i).replace /^[a-z]/ig,($1) =>$1.toLocaleUpperCase()


  # @doc创建简单的Cs 模板
  create_cs: (project_path)->
    pub_dir = path.join project_path,emp.CHA_PUBLIC_DIR
    cs_dir = path.join pub_dir, emp.OFF_EXTENSION_CS;
    channels_dir = path.join cs_dir, emp.OFF_DEFAULT_BASE
    cha_dir = path.join channels_dir, @id
    emp.mkdir_sync(pub_dir)
    emp.mkdir_sync(cs_dir)
    emp.mkdir_sync(channels_dir)
    emp.mkdir_sync(cha_dir)

    pro_dir = path.join __dirname, '../../../', emp.STATIC_CHANNEL_TEMPLATE, @entry_dir
    tmp_cs_dir = path.join pro_dir,emp.STATIC_CS_TEMPLATE
    cs_template = fs.readFileSync tmp_cs_dir, 'utf8'
    cs_template = cs_template.replace(/\$channel/ig, @id)

    for key,obj of @adapters
      tmp_tran = key
      tmp_view = obj.view
      # console.log "view name : #{tmp_view}"
      tmp_cs_file = path.join cha_dir, (tmp_view+'.'+emp.OFF_EXTENSION_CS)
      # console.log "tmp_cs_file: #{tmp_cs_file}"
      if !fs.existsSync tmp_cs_file
        tmp_cs_con = cs_template.replace(/\$trancode/ig, tmp_tran)
        # console.log "fs not exist:#{tmp_cs_file}"
        fs.writeFile tmp_cs_file, tmp_cs_con, 'utf8', (err) =>
          if err
            console.error(err)
            emp.show_error("创建辅助Cs代码失败~:#{tmp_cs_file}")

  # @doc 创建离线资源文件
  create_off: (project_path)->
    cha_dir_arr = @initial_dir(project_path)
    cha_dir = cha_dir_arr[0]
    relate_dir = cha_dir_arr[1]
    pro_dir = path.join __dirname, '../../../', emp.STATIC_CHANNEL_TEMPLATE, @entry_dir
    tmp_xhtml_dir = path.join pro_dir,emp.STATIC_OFF_TEMPLATE
    tmp_json_dir = path.join pro_dir,emp.STATIC_CS_TEMPLATE
    xhtml_template = fs.readFileSync tmp_xhtml_dir, 'utf8'
    json_template = fs.readFileSync tmp_json_dir, 'utf8'
    json_template = json_template.replace(/\$channel/ig, @id)
    xhtml_template = xhtml_template.replace(/\$\{app\}/ig, @app).replace(/\$\{channel\}/ig, @id)

    tmp_arr = []
    for key,obj of @adapters
      tmp_arr.push(obj)
    tmp_arr.reverse()
    if tmp_arr.length >1
      tmp_arr.pop()

    for key,obj of @adapters
      tmp_tran = key
      # tmp_view = obj.trancode
      ext_xhtml = emp.OFF_EXTENSION_XHTML
      tmp_xhtml_name = tmp_tran+'.'+ext_xhtml
      tmp_xhtml_file = path.join cha_dir, ext_xhtml, tmp_xhtml_name
      #doc:文件的相对地址


      if !fs.existsSync tmp_xhtml_file
        tmp_xhtml_template = xhtml_template.replace(/\$\{trancode\}/ig, tmp_tran)
        tmp_relate_file = path.join relate_dir, ext_xhtml, tmp_xhtml_name
        tmp_xhtml_template = tmp_xhtml_template.replace(/\$\{atom_related_info\}/ig, tmp_relate_file)

        if next_obj = tmp_arr.pop()
          tmp_xhtml_template = tmp_xhtml_template.replace(emp.EMP_ENTRANCE_NEXT_TRANCODE, next_obj.trancode)
        else
          tmp_xhtml_template = tmp_xhtml_template.replace(emp.EMP_ENTRANCE_NEXT_TRANCODE, "")

        fs.writeFile tmp_xhtml_file, tmp_xhtml_template, 'utf8', (err) =>
          if err
            console.error(err)
            emp.show_error("创建离线资源代码失败~:#{tmp_xhtml_file}")

      ext_json = emp.OFF_EXTENSION_JSON
      tmp_json_file = path.join cha_dir, ext_json, (tmp_tran+'.'+ext_json)
      if !fs.existsSync tmp_json_file
        tmp_json_con = json_template.replace(/\$trancode/ig, tmp_tran)
        fs.writeFile tmp_json_file, tmp_json_con, 'utf8', (err) =>
          if err
            console.error(err)
            emp.show_error("创建离线资源代码失败~:#{tmp_json_file}")

  # @doc 初始化离线资源文件的路径
  initial_dir:(project_path) ->
    pub_dir = path.join project_path,emp.CHA_PUBLIC_DIR
    www_dir = path.join pub_dir, "/www"
    resrc_dir = path.join www_dir, "/resource_dev"
    relate_dir = path.join emp.CHA_PUBLIC_DIR, "/www", "/resource_dev"

    emp.mkdir_sync(pub_dir)
    emp.mkdir_sync(www_dir)
    emp.mkdir_sync(resrc_dir)
    @initial_root_dir(resrc_dir)
    if !@off_detail.plat
      @off_detail.plat = emp.ADAPTER_PLT_D
      @off_detail.res = ''
    adapter_plat = @off_detail.plat
    adapter_res = @off_detail.res
    dest_dir = path.join resrc_dir,adapter_plat
    relate_dir = path.join relate_dir, adapter_plat
    # console.log "dest dir :#{dest_dir}"

    if !fs.existsSync(dest_dir)
      fs.mkdirSync(dest_dir);
      @initial_base_dir(dest_dir)
    cha_dir = ''
    if adapter_plat is emp.ADAPTER_PLT_D
      cha_dir = path.join dest_dir,emp.OFF_DEFAULT_BASE,@id
      relate_dir = path.join relate_dir,emp.OFF_DEFAULT_BASE,@id
      @initial_cha_temp_dir(cha_dir)
    else if (adapter_plat isnt emp.ADAPTER_PLT_D) and !adapter_res
      cha_dir = path.join dest_dir,emp.OFF_COMMON_BASE,emp.OFF_DEFAULT_BASE,@id
      relate_dir = path.join relate_dir,emp.OFF_COMMON_BASE,emp.OFF_DEFAULT_BASE,@id
      @initial_cha_temp_dir(cha_dir)
    else
      res_dir = path.join dest_dir,adapter_res
      if !fs.existsSync(res_dir)
        fs.mkdirSync(res_dir);
        @initial_channels_dir(res_dir)
      cha_dir = path.join res_dir,emp.OFF_DEFAULT_BASE,@id
      relate_dir = path.join relate_dir,adapter_res, emp.OFF_DEFAULT_BASE,@id
      @initial_cha_temp_dir(cha_dir)
    # console.log cha_dir
    [cha_dir, relate_dir]

  # @doc 构建 离线资源的根目录（平台） root=/resource_dev/plateform
  initial_root_dir: (resrc_dir) ->
    for dir in emp.OFF_CHA_PLT_LIST
      tmp_dir = path.join resrc_dir,dir
      if !fs.existsSync(tmp_dir)
        fs.mkdirSync(tmp_dir);
      if dir isnt emp.ADAPTER_PLT_D
        @initial_base_dir(tmp_dir)
      else
        @initial_channels_dir(tmp_dir)

  # @doc 构建分辨率级别目录，默认为 base = root(上述路径)/default
  initial_base_dir: (tmp_dir) ->
    for dir in emp.OFF_BASE_DIR_LIST
      base_dir = path.join tmp_dir,dir
      if !fs.existsSync(base_dir)
        fs.mkdirSync(base_dir);
      @initial_channels_dir(base_dir)

  # @doc 构建通用资源目录 ，默认为 common_src = base/channel
  initial_channels_dir: (base_dir) ->
    for dir in emp.COMMON_DIR_LIST
      tmp_dir = path.join base_dir,dir
      if !fs.existsSync(tmp_dir)
        fs.mkdirSync(tmp_dir);
      if dir is emp.OFF_DEFAULT_BASE
        cha_dir = path.join tmp_dir,@id

        if !fs.existsSync(cha_dir)
          fs.mkdirSync(cha_dir);

  # @doc 构建指定 channel 的资源存放路径
  initial_cha_temp_dir:(cha_dir) ->
    for dir in emp.OFF_CHA_DIR_LIST
      tmp_dir = path.join cha_dir,dir
      if !fs.existsSync(tmp_dir)
        fs.mkdirSync(tmp_dir);
