local L = LibStub('AceLocale-3.0'):NewLocale('ExG', 'ruRU');

L['ExG'] = "Extended EPGP";
L['Roll Frame'] = 'Розыгрыш';
L['Inventory Frame'] = 'Инвентарь';
L['History Frame'] = function(page, total) return 'История. Страница ' .. (page or 0) .. ' из ' .. (total or 0) .. '.' end;
L['Items Frame'] = function(page, total) return 'Настройки предметов. Страница ' .. (page or 0) .. ' из ' .. (total or 0) .. '.' end;
L['Usage:'] = 'Использование:';
L['to open Options frame'] = 'открыть панель опций';
L['to open Roster frame'] = 'открыть окно списка';
L['ExG General'] = 'Основное';
L['ExG BaseEP'] = 'Базовое EP';
L['ExG BaseGP'] = 'Базовое GP';
L['ExG Items'] = 'Предметы';
L['Open Items Settings'] = 'Открыть настройки предметов';
L['Items import text'] = 'Текст для импорта';
L['Items Loot Settings'] = 'Настройки лута';
L['Loot Threshold'] = 'Порог лута';
L['Loot Threshold Desc'] = 'Порог для распределения лута - выбранное качество и выше';
L['Items Formula'] = 'Формула GP';
L['Items Formula Desc'] = '|cff33ff99КОЭФ * БАЗА ^ [ (УРОВЕНЬ / 26 + КАЧЕСТВО - 4) ] * СЛОТ * МОД|r';
L['Items Formula Coef'] = 'Коэффициенты формулы';
L['Items coef'] = 'КОЭФ';
L['Items base'] = 'БАЗА';
L['Items mod'] = 'МОД';
L['Items head'] = 'Голова';
L['Items neck'] = 'Шея';
L['Items shoulder'] = 'Плечо';
L['Items back'] = 'Спина';
L['Items chest'] = 'Грудь';
L['Items wrist'] = 'Запястья';
L['Items hands'] = 'Кисти рук';
L['Items waist'] = 'Пояс';
L['Items legs'] = 'Ноги';
L['Items feet'] = 'Ступни';
L['Items finger'] = 'Палец';
L['Items trinket'] = 'Аксуссуар';
L['Items weaponMH'] = 'Правая рука';
L['Items weaponOH'] = 'Левая рука';
L['Items holdableOH'] = 'Holdable OH';
L['Items weapon1H'] = 'Одноручное';
L['Items weapon2H'] = 'Двуручное';
L['Items shield'] = 'Щит';
L['Items wand'] = 'Жезл';
L['Items ranged'] = 'Дальнобойное';
L['Items relic'] = 'Реликвия';
L['Items thrown'] = 'Метательное';
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
L['Master'] = 'Мастер';
L['Description'] = 'Описание';
L['EP'] = true;
L['GP'] = true;
L['ExG Debug'] = 'Режим отладки';
L['ExG Debug Desc'] = 'В режиме отладки не происходит сохранение значений EP и GP в офицерские записки';
L['ExG Bosses'] = 'Боссы';
L['ExG Bosses MC'] = 'Огненные Недра';
L['ExG Bosses BWL'] = 'Логово Крыла Тьмы';
L['ExG Bosses ZG'] = 'Зул\'Гуруб';
L['ExG Bosses AK20'] = 'Руины Ан\'Киража';
L['ExG Bosses AK40'] = 'Ан\'Кираж';
L['ExG Bosses NAXX'] = 'Наксрамас';
L['ExG Bosses OTHER'] = 'Остальные';
L['ExG History RAID'] = 'Рейд';
L['ExG History Boss End'] = function(boss, ep) return 'Рейдовый EP ' .. (ep < 0 and '-' or '+') .. (ep or 0) .. ' за ' .. (boss or 'Неизвестно'); end;
L['ExG SetEG'] = function(name, info, ep, gp) return 'EPGP для ' .. (name or 'Неизвестный') .. ' (idx = ' .. (info.index or 0) .. '): ' .. (ep or 0) .. 'ep, ' .. (gp or 0) .. 'gp'; end;
L['History pulled'] = function(data) return '|cff33ff99Получение истории от ' .. (data.source or 'unknown') .. ' за последние ' .. (data.offset or 0) .. ' дней(дня).|r'; end;
L['History imported'] = function(data) return '|cff33ff99Загружено ' .. (data.count or 0) .. ' записей истории. От ' .. date('%d.%m %H:%M:%S', data.min) .. ' по ' .. date('%d.%m %H:%M:%S', data.max) .. '.|r'; end;
L['Pretenders'] = function(roll, attend) return '|cff33ff99Претенденты ' .. (roll or 0) .. ' из ' .. (attend or 0) .. '|r'; end;
L['Total imported'] = function(count) return 'Импортировано записей истории: ' .. (count or 0); end;

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
