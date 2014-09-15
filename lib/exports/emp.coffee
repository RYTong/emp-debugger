# macro defined

module.exports =
  OS_DARWIN:'darwin'
  OS_PATH:'PATH'
  COL_KEY:"collections"
  CHA_KEY:"channels"
  bash_path_key:'emp-debugger.path'
  COL_ROOT_TYPE:1
  COL_CH_TYPE:0
  ITEM_CHA_TYPE:1
  ITEM_COL_TYPE:0
  CHANNEL_ADAPTER:'channel_adapter'
  CHANNEL_NEW_CALLBACK: 'new_callback'
  CHANNEL_CALLBACK: 'channel_callback'
  CHANNEL_PROXY: 'channel_proxy'


  GEN_VIEW:'gen_view'
  ADD_CHA_VIEW:'add_cha_view'


  ATOM_CONF_CHANNEL_DIR_KEY:'emp-debugger.Channel-config-file'
  ATOM_CONF_CHANNEL_DIR_DEFAULT:'/config/channel.conf'


module.exports.show_error = (err_msg) ->
  atom.confirm
    message:"Error"
    detailedMessage:err_msg