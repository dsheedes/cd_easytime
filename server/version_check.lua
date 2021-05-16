Citizen.CreateThread(function()
    Citizen.Wait(5000)
    local resource_name = GetCurrentResourceName()
    local current_version = GetResourceMetadata(resource_name, 'version', 0)
    PerformHttpRequest('https://raw.githubusercontent.com/RampBST/Codesign_Versions/master/'..resource_name..'.txt',function(error, result, headers)
        local new_version = result:sub(1, -2)
        if new_version ~= current_version then
            print('^2['..resource_name..'] - New Update Available.^0\nCurrent Version: ^5'..current_version..'^0\nNew Version: ^5'..new_version..'^0')
        end
    end,'GET')
end)