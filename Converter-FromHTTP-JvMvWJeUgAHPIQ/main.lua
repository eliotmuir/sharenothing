
local Convert = require 'convert'

function main(Data)
   
   local Result = Convert{project='/Users/eliot2/Downloads/Deploy-FromHTTPS.zip'} 
   
   net.http.respond{body=Result, entity_type="application/zip"}
end