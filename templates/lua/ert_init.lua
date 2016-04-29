--- 设置ert框架的debug配置项
-- @param ui_debug  debug总开关,当设置为true时，其他开关才生效
-- @param channel_page  channel流程中当报文不存在与本地离线资源时，是否实时从ewp获取
-- @param channel_json  channel流程中是否直接从ewp获取json模拟数据作为借口返回
-- @param debug_message ert:debug() 是否输出日志
-- @param debug_ert     ert:debug_ert() 是否输出日志

ert:set_debug(true, true, false, true, true);
