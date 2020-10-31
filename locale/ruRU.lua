local L = LibStub('AceLocale-3.0'):NewLocale('ExG', 'ruRU');

local eg = function(val, postfix)
    local tmp = tonumber(val);

    return format('%s%d %s', (tmp or 0) < 0 and ' ' or ' +', tmp or 0, strupper(postfix));
end

L['ExG'] = "Extended EPGP";
L['Roll Frame'] = 'Розыгрыш';
L['Roll Dialog Frame'] = 'Передача предмета';
L['Unit will receive item'] = function(name, link) return format('%s получит %s', name, link); end;
L['Inventory Frame'] = 'Инвентарь';
L['History Frame'] = function(page, total) return format('История. Страница %d из %d.', (page or 0) + 1, total or 0); end;
L['Items Frame'] = function(page, total) return 'Настройки предметов. Страница ' .. (page or 0) .. ' из ' .. (total or 0) .. '.' end;
L['Usage:'] = 'Использование:';
L['to open Options frame'] = 'открыть панель опций';
L['to open Roster frame'] = 'открыть окно списка';
L['to open History frame'] = 'открыть окно истории';
L['to open Inventory Roll frame'] = 'открыть окно ролла из сумок';
L['General'] = 'Основное';
L['Not in Guild'] = 'Не в Гильдии';
L['Base EP'] = 'Базовое EP';
L['Base GP'] = 'Базовое GP';
L['Cancel'] = 'Отмена';
L['Ok'] = 'Ок';
L['Accept option share from this rank and above'] = 'Принимать настройки от этого ранга и выше';
L['ExG Show GP'] = 'Показывать стоимость GP в подсказках';
L['Unit Adjust Desc'] = function(type, diff, reason) return format('Индивидуально %s%d %s%s', diff < 0 and '' or '+', diff, type or 'EP', (reason or '') == '' and '' or format(' (%s)', reason)); end;
L['ExG Report Unit EG'] = function(unit, type, diff, reason) return format('%s получает%s%s', unit or 'Неизвестно', eg(diff, type or 'EP'), (reason or '') == '' and '' or format(' (%s)', reason)); end;
L['ExG Tooltip GP value'] = function(gp) return 'Стоимость GP: ' .. (gp or 0) end;
L['Mass Operations'] = 'Массовые операции';
L['Change Guild EPGP'] = 'EPGP Гильдии';
L['ExG Guid EG'] = function(ep, gp, desc) return format('EPGP Гильдии %s%s%s', eg(ep, 'EP'), eg(gp, 'GP'), (desc or '') == '' and '' or format(' (%s)', desc)); end;
L['ExG Report Guild EG'] = function(ep, gp, desc) return format('Все члены гильдии получают %s%s%s', eg(ep, 'EP'), eg(gp, 'GP'), (desc or '') == '' and '' or format(' (%s)', desc)); end;
L['Change Raid EPGP'] = 'EPGP Рейду';
L['ExG Raid EG'] = function(ep, gp, desc) return format('EPGP Рейда %s%s%s', eg(ep, 'EP'), eg(gp, 'GP'), (desc or '') == '' and '' or format(' (%s)', desc)); end;
L['ExG Report Raid EG'] = function(ep, gp, desc) return format('Все члены рейда получают %s%s%s', eg(ep, 'EP'), eg(gp, 'GP'), (desc or '') == '' and '' or format(' (%s)', desc)); end;
L['Guild Decay'] = 'Понижение';
L['Guild Decay Desc'] = function(percent) return format('Гильдейское понижение EPGP на %d%%', percent or 0); end;
L['Percent'] = 'Процент';
L['Version'] = function(version) return format('Версия v.%s', version); end;
L['Offline'] = 'Оффлайн';
L['No response'] = 'Нет ответа';
L['ExG Items'] = 'Предметы';
L['Open Items Settings'] = 'Открыть настройки предметов';
L['Items import text'] = 'Текст для импорта';
L['Items Loot Settings'] = 'Настройки лута';
L['Loot Threshold'] = 'Порог лута';
L['Loot Threshold Desc'] = 'Порог для распределения лута - выбранное качество и выше';
L['Close item on pass'] = 'Закрывать предметы при пасе';
L['Items Formula'] = 'Формула GP';
L['Items Formula Desc'] = '|cff33ff99КОЭФ * БАЗА ^ [ (УРОВЕНЬ / 26 + КАЧЕСТВО - 4) ] * СЛОТ * МОД|r';
L['Items Formula Coef'] = 'Коэффициенты формулы';
L['Items coef'] = 'КОЭФ';
L['Items base'] = 'БАЗА';
L['Items mod'] = 'МОД';
L['Items INVTYPE_HEAD'] = 'Голова';
L['Items INVTYPE_NECK'] = 'Шея';
L['Items INVTYPE_SHOULDER'] = 'Плечо';
L['Items INVTYPE_CLOAK'] = 'Спина';
L['Items INVTYPE_CHEST'] = 'Грудь';
L['Items INVTYPE_WRIST'] = 'Запястья';
L['Items INVTYPE_HAND'] = 'Кисти рук';
L['Items INVTYPE_WAIST'] = 'Пояс';
L['Items INVTYPE_LEGS'] = 'Ноги';
L['Items INVTYPE_FEET'] = 'Ступни';
L['Items INVTYPE_FINGER'] = 'Палец';
L['Items INVTYPE_TRINKET'] = 'Аксуссуар';
L['Items INVTYPE_WEAPONMAINHAND'] = 'Правая рука';
L['Items INVTYPE_WEAPONOFFHAND'] = 'Левая рука';
L['Items INVTYPE_HOLDABLE'] = 'Носимое слева';
L['Items INVTYPE_WEAPON'] = 'Одноручное';
L['Items INVTYPE_2HWEAPON'] = 'Двуручное';
L['Items INVTYPE_SHIELD'] = 'Щит';
L['Items INVTYPE_RANGED'] = 'Дальнобойное';
L['Items INVTYPE_WAND'] = 'Жезл';
L['Items INVTYPE_RELIC'] = 'Реликвия';
L['Items INVTYPE_THROWN'] = 'Метательное';
L['ExG History'] = 'История';
L['History Common'] = 'Общие';
L['History page size'] = 'Размер страницы';
L['History Exchange'] = 'Обмен историей';
L['History source player'] = 'Игрок-источник';
L['History source offset'] = 'Сдвиг (дней)';
L['History Pull Header'] = 'Получение истории игроков';
L['History Pull'] = 'Получить';
L['Clear'] = 'Очистить';
L['Open History'] = 'Открыть Историю';
L['Import History'] = 'Импорт Истории';
L['Import'] = 'Импорт';
L['ExG Buttons'] = "Кнопки";
L['Button 1'] = 'Кнопка 1';
L['Button 2'] = 'Кнопка 2';
L['Button 3'] = 'Кнопка 3';
L['Button 4'] = 'Кнопка 4';
L['Button 5'] = 'Кнопка 5';
L['Button 6'] = 'Кнопка Пас';
L['Disenchant'] = 'Распылить';
L['ExG History Item'] = function(gp, option) return format('%s (%s)', eg(gp, 'GP'), option or ''); end;
L['ExG Report Item'] = function(unit, link, gp) return format('%s получает %s за%s', unit or 'Неизвестно', link or 'Неизвестно', eg(gp, 'GP')); end;
L['ExG Report Disenchant'] = function(link) return format('%s распылен', link or 'Unknown'); end;
L['ExG History Item Disenchant'] = 'Распылено';
L['Button Text'] = 'Текст';
L['Button Ratio'] = 'Коэфф.';
L['Button Roll'] = 'Ролл';
L['Value must be a not empty string'] = 'Значение должно быть не пустой строкой';
L['Value must be a number'] = 'Значение должно быть числом';
L['Value must be more than X'] = function(val) return 'Значение должно быть больше ' .. (val or 0) end;
L['Player must be in guild'] = 'Игрок должен быть в гильдии';
L['Announce'] = 'Объявить';
L['Refresh'] = 'Обновить';
L['Date'] = '-';
L['Name'] = 'Имя';
L['Rank'] = 'Ранг';
L['Class'] = 'Класс';
L['Master'] = 'Мастер';
L['Description'] = 'Описание';
L['Amount'] = 'Сумма';
L['Reason'] = 'Причина';
L['ExG Debug'] = 'Режим отладки';
L['ExG Debug Desc'] = 'В режиме отладки не происходит сохранение значений EP и GP в офицерские записки';
L['Debug mode'] = function(mode) return format('|cff33ff99Режим отладки %s|r', (mode or false) and 'on' or 'off'); end;
L['Share Options'] = 'Поделиться настройками';
L['Share Options Guild'] = 'Поделиться c Гильдией';
L['Share Options Raid'] = 'Поделиться c Рейдом';
L['Options sending'] = function(channel) return format('|cff33ff99Отправляются настройки всем членам %s онлайн|r', channel == 'GUILD' and 'гильдии' or 'рейда'); end;
L['Options sent'] = function(channel) return format('|cff33ff99Настройки отправлены всем членам %s онлайн|r', channel == 'GUILD' and 'гильдии' or 'рейда'); end;
L['Options received'] = function(sender) return format('|cff33ff99Получены настройки от %s|r', sender); end;
L['Options ignored'] = function(sender) return format('|cff33ff99Проигнорированы настройки от %s|r', sender); end;
L['ExG Bosses'] = 'Боссы';
L['ExG Bosses MC'] = 'Огненные Недра';
L['ExG Bosses BWL'] = 'Логово Крыла Тьмы';
L['ExG Bosses ZG'] = 'Зул\'Гуруб';
L['ExG Bosses AK20'] = 'Руины Ан\'Киража';
L['ExG Bosses AK40'] = 'Ан\'Кираж';
L['ExG Bosses NAXX'] = 'Наксрамас';
L['ExG Bosses OTHER'] = 'Остальные';
L['ExG History RAID'] = 'Рейд';
L['ExG Raid'] = 'Рейд';
L['ExG Raid Speedrun'] = 'Спидран';
L['RAID'] = 'Рейд';
L['Raid'] = 'Рейд';
L['raid'] = 'Рейд';
L['RESERVE'] = 'Резерв';
L['Reserve'] = 'Резерв';
L['reserve'] = 'Резерв';
L['ExG History GUILD'] = 'Гильдия';
L['GUILD'] = 'Гильдия';
L['Guild'] = 'Гильдия';
L['guild'] = 'Гильдия';
L['OFFICER'] = 'Офицер';
L['Officer'] = 'Офицер';
L['officer'] = 'Офицер';
L['Group'] = function(number) return format('Группа %d', number or 0); end;
L['Report channel for EPGP events'] = 'Канал для событий EPGP';
L['ExG History Boss End'] = function(boss, ep) return 'EP Рейда ' .. (ep < 0 and '' or '+') .. (ep or 0) .. ' за ' .. (boss or 'Неизвестно'); end;
L['ExG Report Boss'] = function(boss, ep) return format('Босс %s зверски убит. Все участники рейда получают%s', (boss or 'Unknown'), eg(ep, 'EP')); end;
L['History pulled'] = function(data) return '|cff33ff99Получение истории от ' .. (data.source or 'unknown') .. ' за последние ' .. (data.offset or 0) .. ' дней(дня).|r'; end;
L['History imported'] = function(data) return '|cff33ff99Загружено ' .. (data.count or 0) .. ' записей истории. От ' .. date('%d.%m %H:%M:%S', data.min) .. ' по ' .. date('%d.%m %H:%M:%S', data.max) .. '.|r'; end;
L['Pretenders'] = function(roll, attend) return '|cff33ff99Претенденты ' .. (roll or 0) .. ' из ' .. (attend or 0) .. '|r'; end;
L['Total imported'] = function(count) return 'Импортировано записей истории: ' .. (count or 0); end;
L['View Guild'] = 'Гильдия';
L['View Raid'] = 'Рейд';
L['View Reserve'] = 'Резерв';
L['View Options'] = 'Настройки';
L['Class Filter'] = 'Фильтр Класса';
L['Rank Filter'] = 'Фильтр Ранга';
L['DEATHKNIGHT'] = 'Рыцарь Смерти';
L['WARRIOR'] = 'Воин';
L['ROGUE'] = 'Разбойник';
L['MAGE'] = 'Маг';
L['PRIEST'] = 'Жрец';
L['WARLOCK'] = 'Чернокнижник';
L['HUNTER'] = 'Охотник';
L['SHAMAN'] = 'Шаман';
L['DRUID'] = 'Друид';
L['MONK'] = 'Монах';
L['PALADIN'] = 'Паладин';
L['Report'] = 'Сообщить';
L['Need to update ExG version'] = function(version) return format('Нужно обновить аддон ExG до %s', version and ('версии ' .. version) or 'последней версии'); end;
L['Undecided yet'] = 'Не определились';
L['Critical error occurs'] = function(module, method, message) return format('|cffC41F3BКритическая ошибка в |r%s:%s|cffC41F3B. Детали: |r%s|cffC41F3B.\nПолучите настройки от мастерлутера и |r/reload ui', module, method, message); end;

L['ExG Boss 785'] = 'Верховная жрица Джеклик';
L['ExG Boss 784'] = 'Верховный жрец Веноксис';
L['ExG Boss 786'] = 'Верховная жрица Мар\'ли';
L['ExG Boss 787'] = 'Мандокир Повелитель Крови';
L['ExG Boss 788'] = 'Край Безумия';
L['ExG Boss 789'] = 'Верховный жрец Текал';
L['ExG Boss 790'] = 'Газ\'ранка';
L['ExG Boss 791'] = 'Верховная жрица Арлокк';
L['ExG Boss 792'] = 'Джин\'до Проклинатель';
L['ExG Boss 793'] = 'Хаккар';
L['ExG Boss 663'] = 'Люцифрон';
L['ExG Boss 664'] = 'Магмадар';
L['ExG Boss 665'] = 'Гееннас';
L['ExG Boss 666'] = 'Гарр';
L['ExG Boss 667'] = 'Шаззрах';
L['ExG Boss 668'] = 'Барон Геддон';
L['ExG Boss 669'] = 'Предвестник Сульфурон';
L['ExG Boss 670'] = 'Големагг Испепелитель';
L['ExG Boss 671'] = 'Мажордом Экзекутус';
L['ExG Boss 672'] = 'Рагнарос';
L['ExG Boss 610'] = 'Бритвосмерт Неукротимый';
L['ExG Boss 611'] = 'Валестраз Порочный';
L['ExG Boss 612'] = 'Предводитель драконов Разящий Бич';
L['ExG Boss 613'] = 'Огнечрев';
L['ExG Boss 614'] = 'Черноскал';
L['ExG Boss 615'] = 'Пламегор';
L['ExG Boss 616'] = 'Хроммагус';
L['ExG Boss 617'] = 'Нефариан';
L['ExG Boss 718'] = 'Куриннакс';
L['ExG Boss 719'] = 'Генерал Раджакс';
L['ExG Boss 720'] = 'Моам';
L['ExG Boss 721'] = 'Буру Ненасытный';
L['ExG Boss 722'] = 'Аямисса Охотница';
L['ExG Boss 723'] = 'Оссириан Неуязвимый';
L['ExG Boss 709'] = 'Пророк Скерам';
L['ExG Boss 710'] = 'Три жука';
L['ExG Boss 711'] = 'Боевой страж Сартура';
L['ExG Boss 712'] = 'Фанкрисс Непреклонный';
L['ExG Boss 713'] = 'Нечистотон';
L['ExG Boss 714'] = 'Принцесса Хухуран';
L['ExG Boss 715'] = 'Императоры-близнецы';
L['ExG Boss 716'] = 'Оуро';
L['ExG Boss 717'] = 'К\'Тун';
L['ExG Boss 1084'] = 'Ониксия';
L['ExG Boss 1107'] = 'Ануб\'Рекан';
L['ExG Boss 1110'] = 'Великая вдова Фарлина';
L['ExG Boss 1116'] = 'Мексна';
L['ExG Boss 1117'] = 'Нот Чумной';
L['ExG Boss 1112'] = 'Хейган Нечестивый';
L['ExG Boss 1115'] = 'Мерзот';
L['ExG Boss 1113'] = 'Инструктор Разувиус';
L['ExG Boss 1109'] = 'Готик Жнец';
L['ExG Boss 1121'] = 'Четыре всадника';
L['ExG Boss 1118'] = 'Лоскутик';
L['ExG Boss 1111'] = 'Гроббулус';
L['ExG Boss 1108'] = 'Глут';
L['ExG Boss 1120'] = 'Таддиус';
L['ExG Boss 1119'] = 'Сапфирон';
L['ExG Boss 1114'] = 'Кел\'Тузад';
