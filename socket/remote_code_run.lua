
--[[
 **
 ** roberto-dias, 17 - Março 2020
 **
 ** rcrun, is remote code run  
 ** um servidor  tcp  que posibilita a execução 
 ** de códicos de forma remota
--]]

local sock = require("socket")
local bs64 = require("base64")
local prog = 'gcc'


local chck_mime = function( mime ) 
	local _codeExc = {
		['.c']   = {0,"gcc","-o saida.run"},
		['.lua'] = {1,"lua5.1"},
		['.py'] = {1,"python"},
		['.js'] = {1,"node"},
		['.sh'] = {1,"bash"},
		['.pl'] = {1,"perl"}
	}
	
	if _codeExc[mime] ~= nil then 
		prog = _codeExc[mime]
		return true
	end 
	return false
end


local exec = function(code,mime) 
	local tmp_name = os.tmpname()..mime
	local tmp_file = io.open(tmp_name,"w+")

	tmp_file:write(code)
	tmp_file:flush()

    local s,p,arg = unpack(prog)
    
	if s == 0 then 
		local command = p.." "..tmp_name.." "..arg
		local a,b,status = os.execute(command)
        
		if status == 0 then
			local output = io.popen("./saida.run"):read("*a")
			os.remove("saida.run")
			return output
		end

		tmp_file:close()
		return io.popen(command):read("*a")
	else
		local command = p.." "..tmp_name
		local output = io.popen(command):read("*a")
		tmp_file:close()
		return output
	end
end


local __main__ = function()
	local server = sock.tcp()
	local ip,port = "127.0.0.1", 8080
    local mime = false

	server:bind(ip,port)
	server:listen() 
	print("runing on "..ip..":"..port.."\n")

	while(true) do
	
		local a_sock = server:accept()
		local b_sock = a_sock:receive("*l")
        
		if chck_mime(b_sock) and #b_sock <= 4 then 
			a_sock:send("its-ok")
			mime = tostring(b_sock)
		else
			a_sock:send(exec(bs64.decode(b_sock),mime))
		end
	end
end

__main__()


--[[
	passo 1: envia a extenção
	passo 2: espere a confirmação (its-ok)
	passo 3: envie o códico em base64
	passo 4: aguarde os resultados.
]]--
