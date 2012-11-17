//
//  Resources.h
//  witrapp
//
//  Created by kronik on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifdef NO_DEBUG
#define DO_BACKUP 0 //DO NOT CHANGE THIS!!!
#else
#define DO_BACKUP 0 //Set it to 1 if you need to regenerate index and db
#endif

#ifdef LITE_VERSION
#define LITE_VER 1
#else
#define LITE_VER 0
#endif

#ifdef RU_APP
#define RU_LANG 1
#else
#define RU_LANG 0
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:(((float)((rgbValue & 0xFF0000) >> 16))/255.0) green:(((float)((rgbValue & 0xFF00) >> 8))/255.0) blue:(((float)(rgbValue & 0xFF))/255.0) alpha:1.0]

#if RU_LANG

#define APP_LICENCE_TEXT  @"Все содержимое данного приложения, в том числе словарная база, предназначено исключительно в информационных целях. Данная информация не должна считаться полной или самой последней, и не должна рассматриваться как замена посещения, консультации или совета профессионального врача, юриста или иного специалиста."

#define APP_LOCALE_RU @"ru_RU"
#define RECOGNIZE_LOCALE_RU @"ru-RU"
#define APP_LOCALE_EN @"en_US"
#define RECOGNIZE_LOCALE_EN @"en-US"

#define WORD_NOT_FOUND_TXT @"Не найдено"
#define SIMILAR_WORDS_TXT @"Схожие слова: %d"
#define SEARCH_ONLINE_TXT @"Искать в ..."
#define FULL_MATCH_TXT @"Полное совпадение: %d"
#define ONE_CHANGE_MATCH_TXT @"С одним изменением: %d"
#define TWO_CHANGES_MATCH_TXT @"С двумя изменениями: %d"
#define THREE_CHANGES_MATCH_TXT @"С тремя изменениями: %d"
#define CHECK_WORD_ONLINE_TXT @"Посмотреть '%@' в ..."
#define CANCEL_TXT @"Отмена"
#define STOP_TXT @"Стоп"

#define WIKTIONARY_RU @"Викисловарь"
#define WIKIPEDIA_RU   @"Википедия"
#define YANDEX_RU      @"Яндекс-словарь"
#define GOOGLE_RU      @"Google"

#define WIKTIONARY_EN @"Wiktionary"
#define WIKIPEDIA_EN   @"Wikipedia"
#define YANDEX_EN      @"Merriam-Webster"
#define GOOGLE_EN      @"Dictionary.com"

#define WIKTIONARY_URL_RU @"http://ru.wiktionary.org/wiki/%@"
#define WIKIPEDIA_URL_RU @"http://ru.wikipedia.org/wiki/%@"
#define YANDEX_URL_RU @"http://m.slovari.yandex.ru/spelling.xml?text=%@&mode=full"
#define GOOGLE_URL_RU @"http://www.google.ru/search?sourceid=ios&ie=UTF-8&q=%@"

#define WIKTIONARY_URL_EN @"http://en.wiktionary.org/wiki/%@"
#define WIKIPEDIA_URL_EN @"http://en.wikipedia.org/wiki/%@"
#define YANDEX_URL_EN @"http://www.merriam-webster.com/dictionary/%@"
#define GOOGLE_URL_EN @"http://m.dictionary.com/d/?q=%@"

#define LOCAL_DICTIONARY @"Толковый Словарь"
#define ATTENTION_TXT @"Внимание"
#define ERROR_TXT @"Ошибка"
#define UNABLE_TO_LOAD_WEBPAGE_TXT @"Невозможно загрузить страницу"
#define BACK_TXT @"Назад"
#define SEARCH_HINT @"Новый поиск"
#define FEATURE_NOT_AVAILABLE @"Эта функция доступна только в полной версии приложения"
#define RULES_TXT @"Правила русского языка"

#define NO_SUCH_WORD_IN_DICT @"В словаре отсутствует запись по выбранному слову"

#define APPSTOREID ((LITE_VER==0) ? 493483440:495094894)
#define APPLICATION_NAME @"Жи-Ши"
#define LIKE_THIS_APP @"Понравилось приложение?"
#define PLEASE_RATE_APP @"Пожалуйста, оцените его в App Store"
#define RATE_TXT @"Оценить"
#define NO_LATER_TXT @"Нет, спасибо"
#define DO_LATER_TXT @"Сделаю это позже"

#define ALPHABET_RU @" ,-.абвгдеёжзийклмнопрстуфхцчыьъэюя"
#define ALPHABET_EN @" ,-.abcdefghjiklmnopqrstuvwxyz"

#define APP_LAUNCHES_COUNT_KEY @"WITR_APP_LAUNCHES_COUNT_KEY_RU"

#else

#define APP_LICENCE_TEXT  @"All content on this application, including dictionary database is for informational purposes only. This information should not be considered complete, up to date, and is not intended to be used in place of a visit, consultation, or advice of a medical, legal, or any other professional."

#define APP_LOCALE @"en_US"
#define RECOGNIZE_LOCALE @"en-US"
#define WORD_NOT_FOUND_TXT @"Not found"
#define SIMILAR_WORDS_TXT @"Similar words: %d"
#define SEARCH_ONLINE_TXT @"Search in ..."
#define FULL_MATCH_TXT @"Full match: %d"
#define ONE_CHANGE_MATCH_TXT @"Match with one edit: %d"
#define TWO_CHANGES_MATCH_TXT @"Match with two edits: %d"
#define THREE_CHANGES_MATCH_TXT @"Match with three edits: %d"
#define CHECK_WORD_ONLINE_TXT @"Search '%@' in ..."
#define CANCEL_TXT @"Cancel"
#define STOP_TXT @"Stop"
#define WIKTIONARY @"Wiktionary"
#define WIKIPEDIA   @"Wikipedia"
#define YANDEX      @"Merriam-Webster"
#define GOOGLE      @"Dictionary.com"
#define LOCAL_DICTIONARY @"Offline Dictionary"
#define ATTENTION_TXT @"Attention"
#define ERROR_TXT @"Error"
#define UNABLE_TO_LOAD_WEBPAGE_TXT @"Unable to load this page"
#define WIKTIONARY_URL @"http://en.wiktionary.org/wiki/%@"
#define WIKIPEDIA_URL @"http://en.wikipedia.org/wiki/%@"
#define YANDEX_URL @"http://www.merriam-webster.com/dictionary/%@"
#define GOOGLE_URL @"http://m.dictionary.com/d/?q=%@"
#define BACK_TXT @"Back"
#define SEARCH_HINT @"New search"

#define APPSTOREID ((LITE_VER==0) ? 496458462:496474959)
#define APPLICATION_NAME @"iSpellIt"
#define LIKE_THIS_APP @"Like this app?"
#define PLEASE_RATE_APP @"Please rate it in the App Store"
#define RATE_TXT @"Rate It Now"
#define NO_LATER_TXT @"No, Thanks"
#define DO_LATER_TXT @"Remind Me Later"

#define FEATURE_NOT_AVAILABLE @"This feature available in Full Version of iSpellIt only"
#define NO_SUCH_WORD_IN_DICT @"Word definition not found for selected word"
#define RULES_TXT @"Rules"

#define ALPHABET      @" ,-.abcdefghjiklmnopqrstuvwxyz"
#define APP_LAUNCHES_COUNT_KEY @"WITR_APP_LAUNCHES_COUNT_KEY_EN"
#endif
