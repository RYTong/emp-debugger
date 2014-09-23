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
                {"pubsub",pubsub ,[{decrypt, false}, {verify, false}]},
                {{"${app}","about"},{${app},about},[{decrypt, false}, {verify, true}]},
                {{"${app}","push"},{${app},push},[{decrypt, true}, {verify, true}]},
                {{"unit","unit"},{unit,unit},[{decrypt, false}, {verify, false}]},
                {{"push","register"},{push,register},[{decrypt, false}, {verify, false}]},
                {{"${app}_s","getui"},{${app},getui},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","check_phone_num"},{${app},check_phone_num},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","question"},{${app},entry},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","unlogin"},{${app},unlogin},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","searchmenu"},{${app},searchmenu},[{decrypt, true}, {verify, true}]},
                {{"${app}_s","passwordEncoding"},{${app},passwordEncoding},[{decrypt, true}, {verify, true}]}]},
  %{plugins,[channel,user,ota,security,migrate]},
  {plugins, [channel,security]},
  {menu, mnesia},

  {migrate_version, [
      {mnesia, 1}
  ]}
]}.
