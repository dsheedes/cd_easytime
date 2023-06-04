CreateThread(function()
    Wait(5000)
    local function ToNumber(cd) return tonumber(cd) end
    local resource_name = GetCurrentResourceName()
    local current_version = GetResourceMetadata(resource_name, 'version', 0)
    local docs_link = 'https://docs.codesign.pro/free-scripts/easytime-time-and-weather-management#changelog'
    local download_link = 'https://keymaster.fivem.net/asset-grants'
    PerformHttpRequest('https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/master/'..resource_name..'.txt',function(error, result, headers)
        if not result then print('^1Version check disabled because github is down.^0') return end
        local result = json.decode(result:sub(1, -2))
        if ToNumber(result.version:gsub('%.', '')) > ToNumber(current_version:gsub('%.', '')) then
            local self = {}
            self.current, self.new = {}, {}
            for cd in current_version:gsub('%f[.]%.%f[^.]', '\0'):gmatch'%Z+' do 
                self.current[#self.current+1] = cd
            end
            for cd in result.version:gsub('%f[.]%.%f[^.]', '\0'):gmatch'%Z+' do 
                self.new[#self.new+1] = cd
            end
            
            local current_version, new_version = '', ''
            for c, d in pairs(self.current) do
                if d == self.new[c] then
                    current_version = current_version..'^5'..d..'.^0'
                    new_version = new_version..'^5'..self.new[c]..'.^0'
                else
                    current_version = current_version..'^1'..d..'^5.^0'
                    new_version = new_version..'^2'..self.new[c]..'^5.^0'
                end
            end
            current_version = current_version:sub(1, -4)
            new_version = new_version:sub(1, -4)

            local release_date = math.floor(os.difftime(os.time(), os.time{day = result.release_date.day, month = result.release_date.month, year = result.release_date.year}) / 86400)
            if release_date == 0 then
                release_date = 'Today'
            elseif release_date == 1 then
                release_date = 'Yesterday'
            elseif release_date >= 2 then
                release_date = release_date..' days ago'
            end

            local symbols = '^2'
            for cd = 1, #docs_link+12 do
                symbols = symbols..'='
            end
            symbols = symbols..'^0'
            print(symbols)
            print(string.format('^2[%s] - New Update Available!^0\nCurrent Version: ^5%s^0.\nNew Version: ^5%s^0.\nReleased: ^5%s^0.\nNotes: ^5%s^0.\nDownload: ^3%s^0.\nChangelog: ^3%s^0.', 
            resource_name, current_version, new_version, release_date, result.notes, download_link, docs_link))
            print(symbols)
        end
    end,'GET')
end)