Config.Locales = { --Customise the server sided notification messages.
    ['EN'] = {
        ['invalid_permissions'] = 'You do not have permissions to use this command',
    },

    ['FR'] = {
        ['invalid_permissions'] = 'Vous ne disposez pas des autorisations nécessaires pour utiliser cette commande',
    },

    ['ES'] = {
        ['invalid_permissions'] = 'No tienes permisos para usar este comando',
    },
}

function Notification(source, message)
    if Config.ServerNotification_Type == 'chat' then
        TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message info"> <div class="chat-message-header"> <class="chat-message-body"> '..message})

    elseif Config.ServerNotification_Type == 'mythic_old' then
        TriggerClientEvent('mythic_notify:client:SendAlert:custom', source, { type = 'error', text = message, length = 10000})

    elseif Config.ServerNotification_Type == 'mythic_new' then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = message, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })

    elseif Config.ServerNotification_Type == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)

    elseif Config.ServerNotification_Type == 'custom' then
        --enter custom notification here
    end
end