local Methods = {}

local function ReadSharedFile(Name)
   local FileName = iguana.workingDir()
           ..iguana.project.root()
           .."shared/"
           ..Name:sub(1, #Name-4):gsub("%.", "/")
           ..".lua"
   trace(FileName)
   local F = io.open(FileName, "rb")
   local Content = F:read("*a")
   F:close();
   return Content
end

local function ReadOtherFile(Name)
   local FileName = iguana.workingDir()
           ..iguana.project.root()
           .."other/"
           ..Name
   trace(FileName)
   local F = io.open(FileName, "rb")
   local Content = F:read("*a")
   F:close();
   return Content
end

local function ReadLocalFile(Name)
   local FileName = iguana.workingDir()
           ..iguana.project.root()
           ..iguana.project.guid()
           .."/"
           ..Name:sub(1, #Name-4):gsub("%.", "/")
           ..".lua"
   trace(FileName)
   local F = io.open(FileName, "rb")
   local Content = F:read("*a")
   F:close();
   return Content
end


function Methods.addSharedFile(P, Name, Content)
   if not Content then
      Content = ReadSharedFile(Name)
   end
   local Dirs = Name:split(".")
   local T = P["shared"]
   for i=1, #Dirs-2 do
      if not T[Dirs[i]] then
         T[Dirs[i]] = {}
      end
      T = T[Dirs[i]]
   end
   T[Dirs[#Dirs-1]..".lua"] = Content
   
   P.project["project.prj"].LuaDependencies
   [#P.project["project.prj"].LuaDependencies+1] = Name:sub(1, #Name-4)
   trace(P)
end

function Methods.addOtherFile(P, Name, Content)
   if not Content then
      Content = ReadOtherFile(Name)
   end
   local Dirs = Name:split("/")
   local T = P["other"]
   for i=1, #Dirs-1 do
      if not T[Dirs[i]] then
         T[Dirs[i]] = {}
      end
      T = T[Dirs[i]]
   end
   T[Dirs[#Dirs]] = Content
   
   P.project["project.prj"].OtherDependencies
   [#P.project["project.prj"].OtherDependencies+1] = Name
   trace(P)
end

function Methods.addLocalFile(P, Name, Content)
   if not Content then
      Content = ReadLocalFile(Name)
   end
   local Dirs = Name:split(".")
   local T = P.project
   for i=1, #Dirs-2 do
      if not T[Dirs[i]] then
         T[Dirs[i]] = {}
      end
      T = T[Dirs[i]]
   end
   local Parts = Name:split(".")
   local Extension = "."..Parts[#Parts]
   trace(Extension)
   T[Dirs[#Dirs-1]..Extension] = Content
   
   P.project["project.prj"].LocalDependencies
   [#P.project["project.prj"].LocalDependencies+1] 
      = Name:sub(1, #Name-#Extension):gsub("%.", "/")..Extension
   trace(P)
end

function Methods.main(P,Content)
   P.project["main.lua"] = Content
end

function Methods.compile(P)
   P.project["project.prj"] = json.serialize{data=P.project["project.prj"]}
   P["Export-sdfs"] = P.project
   trace(P)
   P.project = nil
   
   return _G.filter.zip.deflate(P)
end

local MT = {}

MT.__index = Methods

local function Project()
   local P = {shared={}, project={}, other={}}
   P.project["main.lua"]="--This is the main"
   P.project["project.prj"] = {version_info={minor=0, major=6, build=0}}
   P.project["project.prj"].LocalDependencies = {}
   P.project["project.prj"].LuaDependencies = {}
   P.project["project.prj"].OtherDependencies = {}
   P.project["project.prj"].timestamp = os.ts.time()   
   setmetatable(P, MT)
   return P
end

return Project