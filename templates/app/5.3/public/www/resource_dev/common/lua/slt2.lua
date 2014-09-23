--[[
-- slt2 - Simple Lua Template 2
--
-- Project page: https://github.com/henix/slt2
--
-- @License
-- MIT License
--
-- @Copyright
-- Copyright (C) 2012-2013 henix.
--]]

slt2 = {}

-- a tree fold on inclusion tree
-- @param init_func: must return a new value when called
local function include_fold(template, start_tag, end_tag, fold_func, init_func)
	local result = init_func()

	start_tag = start_tag or '#{'
	end_tag = end_tag or '}#'
	local start_tag_inc = start_tag..'include:'

	local start1, end1 = string.find(template, start_tag_inc, 1, true)
	local start2 = nil
	local end2 = 0

	while start1 ~= nil do
		if start1 > end2 + 1 then -- for beginning part of file
			result = fold_func(result, string.sub(template, end2 + 1, start1 - 1))
		end
		start2, end2 = string.find(template, end_tag, end1 + 1, true)
		assert(start2, 'end tag "'..end_tag..'" missing')
		do -- recursively include the file
			local filename = assert(loadstring('return '..string.sub(template, end1 + 1, start2 - 1)))()
			assert(filename)
			-- local t = file:read(filename, "text");
			local fin = assert(io.open(filename))
			-- TODO: detect cyclic inclusion?
			result = fold_func(result, include_fold(fin:read('*a'), start_tag, end_tag, fold_func, init_func), filename)
			-- result = fold_func(result, include_fold(t, start_tag, end_tag, fold_func, init_func), filename)
			fin:close()
		end
		start1, end1 = string.find(template, start_tag_inc, end2 + 1, true)
	end
	result = fold_func(result, string.sub(template, end2 + 1))
	return result
end

-- preprocess included files
-- @return string
function slt2.precompile(template, start_tag, end_tag)
	return table.concat(include_fold(template, start_tag, end_tag, function(acc, v)
		if type(v) == 'string' then
			table.insert(acc, v)
		elseif type(v) == 'table' then
			table.insert(acc, table.concat(v))
		else
			error('Unknown type: '..type(v))
		end
		return acc
	end, function() return {} end))
end

-- unique a list, preserve order
local function stable_uniq(t)
	local existed = {}
	local res = {}
	for _, v in ipairs(t) do
		if not existed[v] then
			table.insert(res, v)
			existed[v] = true
		end
	end
	return res
end

-- @return { string }
function slt2.get_dependency(template, start_tag, end_tag)
	return stable_uniq(include_fold(template, start_tag, end_tag, function(acc, v, name)
		if type(v) == 'string' then
		elseif type(v) == 'table' then
			if name ~= nil then
				table.insert(acc, name)
			end
			for _, subname in ipairs(v) do
				table.insert(acc, subname)
			end
		else
			error('Unknown type: '..type(v))
		end
		return acc
	end, function() return {} end))
end

-- @return { name = string, code = string / function}
function slt2.loadstring(template, start_tag, end_tag, tmpl_name)
	-- compile it to lua code
	local lua_code = {}

	start_tag = start_tag or '#{'
	end_tag = end_tag or '}#'

	local output_func = "coroutine.yield"

	template = slt2.precompile(template, start_tag, end_tag)

	local start1, end1 = string.find(template, start_tag, 1, true)
	local start2 = nil
	local end2 = 0

	local cEqual = string.byte('=', 1)

	while start1 ~= nil do
		if start1 > end2 + 1 then
			table.insert(lua_code, output_func..'('..string.format("%q", string.sub(template, end2 + 1, start1 - 1))..')')
		end
		start2, end2 = string.find(template, end_tag, end1 + 1, true)
		assert(start2, 'end_tag "'..end_tag..'" missing')
		if string.byte(template, end1 + 1) == cEqual then
			table.insert(lua_code, output_func..'('..string.sub(template, end1 + 2, start2 - 1)..')')
		else
			table.insert(lua_code, string.sub(template, end1 + 1, start2 - 1))
		end
		start1, end1 = string.find(template, start_tag, end2 + 1, true)
	end
	table.insert(lua_code, output_func..'('..string.format("%q", string.sub(template, end2 + 1))..')')

	local ret = { name = tmpl_name or '=(slt2.loadstring)' }
	if setfenv == nil then -- lua 5.2
		ret.code = table.concat(lua_code, '\n')
	else -- lua 5.1
		ret.code = assert(loadstring(table.concat(lua_code, '\n'), ret.name))
	end
	return ret
end

-- @return the file get from ewp service
-- the filename is the same as channels file.
local function getfile(filename)
    local path = "name="..utility:escapeURI("channels/"..filename);
    local page = ryt:post(nil, "test_s/get_page", path, nil, nil, true);
    return page;     
end;

-- @return { name = string, code = string / function }
function slt2.loadfile(filename, start_tag, end_tag)
    --if file is not exist then get it from ewp service.
    local t ;
    if file:isExist(filename) ~= true then
        t= getfile(filename);
    else
        t = file:read(filename, "text");
    end;
    return slt2.loadstring(t)
	--local fin = assert(io.open(filename))
	--local all = fin:read('*a')
	--fin:close()
	--return slt2.loadstring(all, start_tag, end_tag, filename)
end


local mt52 = { __index = _ENV }
local mt51 = { __index = _G }

-- @return a coroutine function
function slt2.render_co(t, env)
	local f
	if setfenv == nil then -- lua 5.2
		if env ~= nil then
			setmetatable(env, mt52)
		end
		f = assert(load(t.code, t.name, 't', env or _ENV))
	else -- lua 5.1
		if env ~= nil then
			setmetatable(env, mt51)
		end
		f = setfenv(t.code, env or _G)
	end
	return f
end

-- @return string
function slt2.render(t, env)
	local result = {}
	local co = coroutine.create(slt2.render_co(t, env))
	while coroutine.status(co) ~= 'dead' do
		local ok, chunk = coroutine.resume(co)
		if not ok then
			error(chunk)
		end
		table.insert(result, chunk)
	end
	return table.concat(result)
end

-- return slt2

function escapeHTML(str)
    local tt = {
        ['<'] = '&lt;',
        ['>'] = '&gt;'
    }
    str = string.gsub(str, '&', '&amp;')
    str = string.gsub(str, '[<>]', tt)
    return str
end

function slt2.renderfile(filename,paramsTable)
    local file = slt2.loadfile(filename);
    local render_file = slt2.render(file, paramsTable);
    return render_file;
end
