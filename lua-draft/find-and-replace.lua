local targetDir = 'C:\\Workspace\\mobxyj-client\\trunk\\Assets\\Sources\\Script_Lua\\?.lua'
package.path = package.path .. ';' .. targetDir

IsClient = true
class = require("Spark.middleclass")

Excel = {}
SC_StaticDataProvider = class("SC_StaticDataProvider")
require('CoreGameplay/SC_Common/SC_Data/SC_StaticDataProvider')
require('CoreGameplay/SC_Common/Excels/Excel')

Excel.Reload(IsClient, true)
for k,v in pairs(Excel.Monster.GetAll()) do
    if v.ThreatArea == nil then print('ThreatArea is nil', k) end
    if type(v.ThreatArea) ~= 'table' then print('ThreatArea is not 3', k) end
    if #v.ThreatArea ~= 3 then print('ThreatArea is not 3', k) end
end
print('check done')