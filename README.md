# Взаимодейтсвие с API GitHub

Библиотека упрощает взаимодествие с GitHub API из OneScript.

## Установка

### OPM

В консоли выполняем:
```
opm install github
```
### Из файла

Качаем последний релиз со страницы Релизы. Затем из командной строки:
```
opm install -f github*.ospx
```

## Примеры

### Авторизация

Авторизация выполняется по token github. Как получить токен можно почитать [тут](https://github.com/settings/tokens).

```bsl
#Использовать github

Токен = "какой-то-токен";
Клиент = Новый КлиентGitHub(Токен);
```

### Пользователь

Доступные поля:
* Логин
* Идентификатор
* Ссылка
* Имя
* Компания
* Местоположения
* ЭлектроннаяПочта
* Инфо
* Репозиториев
* Подписчиков
* Подписок
* ДатаСоздания
* ДатаОбновления


```bsl
ИмяПользователя = "freeCodeCamp";
Пользователь = Клиент.ПолучитьПользователя(ИмяПользователя);
```
или
```bsl
ИмяПользователя = "freeCodeCamp";
Пользователь = Клиент.ПолучитьПользователя(Новый ПользовательGitHub(ИмяПользователя));
```

### Репозиторий

Доступные поля:
* Идентификатор
* Имя
* ПолноеИмя
* Закрытий
* Пользователь
* Ссылка
* Описание
* ЭтоФорк
* ДатаСоздания
* ДатаОбновления
* ДатаПуша
* СсылкаGit
* СсылкаSSH
* Размер
* Язык
* Лицензия
* Форки
* ВеткаПоУмолчания
* Архивный

```bsl
ИмяПользователя = "freeCodeCamp";
ИмяРепозитория = "freeCodeCamp";
Репозиторий = Клиент.ПолучитьРепозиторий(ИмяПользователя, ИмяРепозитория);
```



