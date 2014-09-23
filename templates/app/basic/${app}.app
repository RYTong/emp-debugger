{application,${app},[
  {description,"Mobile banking demo"},
  {vsn,1.6},
  {modules,[]},
  {applications,[kernel,stdlib,yaws]},
  {registered,[${app}]},
  {env,[{env,development}]},
  {mod,${app}_bootstrap},
  {controllers,[{{"${app}","index"},{${app},index},[{decrypt, false}, {verify, false}]},
                {{"phone","check_cs_server"},{${app},check_cs_server},[{decrypt, false}, {verify, false}]},
                {{"${app}","about"},{${app},about},[{decrypt, false}, {verify, true}]},
                {{"${app}","push"},{${app},push},[{decrypt, true}, {verify, true}]},
                {{"unit","unit"},{unit,unit},[{decrypt, false}, {verify, false}]},
                {{"push","register"},{push,register},[{decrypt, false}, {verify, false}]},
                {{"${app}_s","getui"},{${app},getui},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","check_name"},{${app},check_name},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","check_phone_num"},{${app},check_phone_num},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","write_phone_num"},{${app},write_phone_num},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","question"},{${app},entry},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","login"},{${app},login},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","login_filter"},{${app},login_auth},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","get_json_data"},{${app},get_json_data},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","unlogin"},{${app},unlogin},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","searchmenu"},{${app},searchmenu},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","passwordEncoding"},{${app},passwordEncoding},[{decrypt, true}, {verify, true}]}]},
  {plugins,[security]},
  {menu, db},
  
  {migrate_version, [
      {mnesia, 1}
  ]}
]}.
