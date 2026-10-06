Locales = {}

Locales['en'] = {
    -- Male reaction messages
    ['male_reaction_1'] = "Jesus boy, what's wrong with you!",
    ['male_reaction_2'] = "Good lord man, put that away!",
    ['male_reaction_3'] = "What in tarnation!?",
    ['male_reaction_4'] = "You sick bastard!",
    ['male_reaction_5'] = "I'm getting the sheriff!",
    ['male_reaction_6'] = "Mother of God, NO!",
    ['male_reaction_7'] = "Have you no shame!?",

    -- Female reaction messages
    ['female_reaction_1'] = "Boys that's a whopper!",
    ['female_reaction_2'] = "Oh my... well hello there!",
    ['female_reaction_3'] = "Now that's impressive!",
    ['female_reaction_4'] = "Sweet mother of mercy...",
    ['female_reaction_5'] = "I've never seen one so... big!",

    -- Excited near female messages
    ['excited_1'] = "You feel a tingle... a woman is nearby!",
    ['excited_2'] = "You feel a stir in your pants",
    ['excited_3'] = "You feel excited... there's a lady close!",
    ['excited_4'] = "Something is stirring in your underwear...",
    ['excited_5'] = "A woman approaches... you feel aroused!",

    -- Hardon trigger messages
    ['hardon_trigger_1'] = "A beautiful woman is near... you can't control yourself!",
    ['hardon_trigger_2'] = "The sight of her triggers something primal...",
    ['hardon_trigger_3'] = "Your pants reacts to her presence...",
    ['hardon_trigger_4'] = "You suddenly feel very aroused...",
    ['hardon_trigger_5'] = "Something is rising... literally!",

    -- Female following messages
    ['following_1'] = "She can't take her eyes off it...",
    ['following_2'] = "She seems very interested in you...",
    ['following_3'] = "She wants a closer look...",
    ['following_4'] = "She's following you home...",
    ['following_5'] = "You've got an admirer!",

    -- Female stop following messages
    ['stop_following_1'] = "She finally came to her senses...",
    ['stop_following_2'] = "She's seen enough...",
    ['stop_following_3'] = "She got bored and left...",
    ['stop_following_4'] = "Reality hit her and she walked away...",
    ['stop_following_5'] = "She remembered she has a husband...",

    -- General notifications
    ['man_horrified'] = "The man is horrified...",
    ['woman_cant_believe'] = "The woman cant believe her eyes...",
    ['aroused_no_reason'] = "You have become aroused, For No Reason",
    ['calmed_down'] = "You have calmed down...",
    ['nothing_to_calm'] = "Nothing to calm down...",
    ['someone_else_attention'] = "Someone else has your attention...",
    ['auto_hardon_enabled'] = "Auto Hardon: ENABLED",
    ['auto_hardon_disabled'] = "Auto Hardon: DISABLED",

    -- Server messages
    ['no_item'] = "You do not have this item!",
    ['no_permission'] = "You do not have permission to use this command.",

    -- ox_target
    ['show_off_label'] = "Show Off Penis",
}

-- Helper function to get locale
function _L(key)
    local lang = Config.Locale or 'en'
    if Locales[lang] and Locales[lang][key] then
        return Locales[lang][key]
    elseif Locales['en'] and Locales['en'][key] then
        return Locales['en'][key]
    end
    return key
end

-- Helper function to get random locale from a pattern
function _LRandom(pattern, count)
    local index = math.random(1, count)
    return _L(pattern .. '_' .. index)
end
