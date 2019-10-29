#Использовать 1connector
#Использовать "../internal"

Перем ТокенАвторизации;
Перем ВерсияAPI;

Перем Сервер;

Процедура ПриСозданииОбъекта(пТокен = "")

	Если ЗначениеЗаполнено(пТокен) Тогда
		ТокенАвторизации = пТокен;
	КонецЕсли;
	
КонецПроцедуры

Процедура ИспользоватьТокен(Знач Токен) Экспорт
	ТокенАвторизации = Токен;
КонецПроцедуры

Функция ПолучитьПользователя(Знач ИсходящееЗначение) ЭКспорт

	Перем Пользователь;

	Если ТипЗнч(ИсходящееЗначение) = Тип("Строка") Тогда
		Пользователь = Новый ПользовательGitHub(ИсходящееЗначение);
	ИначеЕсли ТипЗнч(ИсходящееЗначение) = Тип("ПользовательGitHub") Тогда
		Пользователь = ИсходящееЗначение;
	Иначе
		ВызватьИсключение ("Тип исходящего значения не поддерживается");
	КонецЕсли;

	СсылкаЗапроса = "/user";
	Если ЗначениеЗаполнено(Пользователь.Логин) Тогда
		СсылкаЗапроса = СсылкаЗапроса + "s/" + Пользователь.Логин;
	КонецЕсли;
	Ответ = КоннекторHTTP.Get(Сервер + СсылкаЗапроса,, Новый Структура("Заголовки", Заголовки()));

	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Пользователь.Заполнить(Данные);
	Иначе
		Пользователь = Неопределено;
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Пользователь;

КонецФункции

Функция ПолучитьРепозиторий(Знач Объект, Знач ИмяРепозитория = "") Экспорт

	Перем Репозиторий;
	Перем ИмяВладельца;

	Если ТипЗнч(Объект) = Тип("ПользовательGitHub") Или ТипЗнч(Объект) = Тип("ОрганизацияGitHub") Тогда
		ИмяВладельца = Объект.Логин;
	ИначеЕсли ТипЗнч(Объект) = Тип("РепозиторийGitHub") Тогда
		Репозиторий = Объект;
	ИначеЕсли ТипЗнч(Объект) = Тип("Строка") Тогда
		ИмяВладельца = Объект;
	Иначе
		ВызватьИсключение("Тип параметра Владелец не поддерживается");
	КонецЕсли;

	Если Репозиторий = Неопределено Тогда
		Репозиторий = Новый РепозиторийGitHub();
	КонецЕсли;

	Если ЗначениеЗаполнено(Репозиторий.ПолноеИмя) Тогда
		СсылкаЗапроса = СтрШаблон("/repos/%1", Репозиторий.ПолноеИмя);
	Иначе
		СсылкаЗапроса = СтрШаблон("/repos/%1/%2", ИмяВладельца, ИмяРепозитория);
	КонецЕсли;

	Ответ = КоннекторHTTP.Get(Сервер + СсылкаЗапроса,, Новый Структура("Заголовки", Заголовки()));
	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Репозиторий.Заполнить(Данные);
	Иначе
		Репозиторий = Неопределено;
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Репозиторий;

КонецФункции

Функция ПолучитьОрганизацию(Знач ИмяОрганизации) Экспорт

	Перем Организация;

	Если ТипЗнч(ИмяОрганизации) = Тип("ОрганизацияGitHub") Тогда
		Организация = ИмяОрганизации;
	ИначеЕсли ТипЗнч(ИмяОрганизации) = Тип("Строка") Тогда
		Организация = Новый ОрганизацияGitHub(ИмяОрганизации);
	Иначе
		ВызватьИсключение("Тип параметра ИмяОрганизации не поддерживается");
	КонецЕсли;

	СсылкаЗапроса = "/orgs/" + Организация.Логин;
	Ответ = КоннекторHTTP.Get(Сервер + СсылкаЗапроса,, Новый Структура("Заголовки", Заголовки()));
	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Организация.Заполнить(Данные);
	Иначе
		Организация = Неопределено;
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Организация;

КонецФункции

Функция ПолучитьРепозиторииПоВладельцу(Знач Владелец, Знач НомерСтраницы = 1, Знач КоличествоНаСтранице = 50) Экспорт

	Перем Список;
	Перем ИмяВладельца;
	
	ТипВладельца = "users";

	Если ТипЗнч(Владелец) = Тип("ПользовательGitHub") Или ТипЗнч(Владелец) = Тип("ОрганизацияGitHub") Тогда
		ИмяВладельца = Владелец.Логин;
		ТипВладельца = ?(ТипЗнч(Владелец) = Тип("ОрганизацияGitHub"), "orgs", "users");
	ИначеЕсли ТипЗнч(Владелец) = Тип("Строка") Тогда
		ИмяВладельца = Владелец;
	Иначе
		ВызватьИсключение("Тип параметра Владелец не поддерживается");
	КонецЕсли;
	
	СсылкаЗапроса = СтрШаблон("/%1/%2/repos", ТипВладельца, ИмяВладельца);
	ПараметраЗапроса = Новый Структура("page, per_page", НомерСтраницы, КоличествоНаСтранице);
	Ответ = КоннекторHTTP.Get(Сервер + СсылкаЗапроса, ПараметраЗапроса, Новый Структура("Заголовки", Заголовки()));
	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Список = Новый Массив;
		Для Каждого Элемент Из Данные Цикл
			Репозиторий = Новый РепозиторийGitHub();
			Репозиторий.Заполнить(Элемент);
			Список.Добавить(Репозиторий);
		КонецЦикла;
	Иначе
		Список = Неопределено;
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Список;

КонецФункции

Функция ПолучитьСотрудниковРепозитория(Знач Пользователь, Знач ИмяРепозитория) Экспорт

	Перем Результат;
	Перем ИмяПользователя;

	Если ТипЗнч(Пользователь) = Тип("ПользовательGitHub") Тогда
		ИмяПользователя = Пользователь.Идентификатор;
	ИначеЕсли ТипЗнч(Пользователь) = Тип("Строка") Тогда
		ИмяПользователя = Пользователь;
	Иначе
		ВызватьИсключение("Тип параметра Пользователь не поддерживается.");
	КонецЕсли;

	Результат = Новый Массив;

	СсылкаЗапроса = СтрШаблон("/repos/%1/%2/collaborators", ИмяПользователя, ИмяРепозитория);
	Ответ = КоннекторHTTP.Get(Сервер + СсылкаЗапроса,, Новый Структура("Заголовки", Заголовки()));
	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Для Каждого ЭлементДанных Из Данные Цикл
			Пользователь = Новый ПользовательGitHub();
			Пользователь.Заполнить(ЭлементДанных);
			Результат.Добавить(Пользователь);
		КонецЦикла;
	Иначе
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция ПолучитьКонтент(Знач Репозиторий, Знач ИмяКонтента) Экспорт

	Перем Контент;

	Если ТипЗнч(Репозиторий) = Тип("РепозиторийGitHub") Тогда
		ИмяРепозитория = Репозиторий.ПолноеИмя;
	ИначеЕсли ТипЗнч(Репозиторий) = Тип("Строка") Тогда
		ИмяРепозитория = Репозиторий;
	Иначе
		ВызватьИсключение("Тип параметра Репозиторий не поддерживается");
	КонецЕсли;

	Контент = Новый КонтентGitHub();
	
	СсылкаЗапроса = СтрШаблон("/repos/%1/%2", ИмяРепозитория, ИмяКонтента);
	Ответ = КоннекторHTTP.Get(Сервер + СсылкаЗапроса,, Новый Структура("Заголовки", Заголовки()));
	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Контент.Заполнить(Данные);
	Иначе
		Контент = Неопределено;
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Контент;

КонецФункции
// <Создает форк репозитория в нужную организацию>
//
// Параметры:
//  <Пользователь>  - <Тип("ПользовательGitHub") или Строка> - <Пользователь, владелец репозитория, который будет форкаться.>
//  <Репозиторий>  - <Тип("РепозиторийGitHub") или Строка> - <Репозиторий, который будет форкаться>
//  <Организация>  - <Тип("ОрганизацияGitHub") или Строка> - <Организация, в которой будет создан форк>
//
// Возвращаемое значение:
//   <Тип("РепозиторийGitHub")>   - <  >
//
Функция СоздатьФоркВОрганизацию(Знач Пользователь, Знач Репозиторий, Знач Организация) Экспорт

	Перем ИмяПользователя;
	Перем ИмяРепозитория;
	Перем ИмяОрганизации;

	ИмяПользователя = Валидация.ЗначениеПоТипу(Пользователь, "ПользовательGitHub");
	ИмяРепозитория = Валидация.ЗначениеПоТипу(Репозиторий, "РепозиторийGitHub");
	ИмяОрганизации = Валидация.ЗначениеПоТипу(Организация, "ОрганизацияGitHub");

	СсылкаЗапроса = СтрШаблон("/repos/%1/%2/forks?organization=%3", ИмяПользователя, ИмяРепозитория, ИмяОрганизации);
	Ответ = КоннекторHTTP.Post(Сервер + СсылкаЗапроса, , , Новый Структура("Заголовки", Заголовки()));
	
	Если Ответ.КодСостояния = 200 Тогда
		Данные = Ответ.Json();
		Репозиторий.Заполнить(Данные);
	Иначе
		Репозиторий = Неопределено;
		Сообщить(Ответ.Текст());	
	КонецЕсли;

	Возврат Репозиторий;

КонецФункции

// <Предоставляет доступ пользователю на пуш к репозиторию>
//
// Параметры:
//  <Владелец>  - <Тип("ПользовательGitHub") или Тип("ОрганизацияGitHub") или Строка> - <Пользователь/Организация, владелец репозитория, к которому предоставляется доступ>
//  <Репозиторий>  - <Тип("РепозиторийGitHub") или Строка> - <Репозиторий, к которому предоставляется доступ>
//  <КомуПредоставитьДоступ>  - <Тип("ПользовательGitHub") или Строка> - <Пользователь, которому предоставляется доступ>
//
// Возвращаемое значение:
//   <Тип("РепозиторийGitHub")>   - <  >
//
Функция ПредоставитьДоступКРепозиторию(Знач Владелец, Знач Репозиторий, Знач КомуПредоставитьДоступ) Экспорт

	Перем ИмяОорганизацииИлиПользователя;
	Перем ИмяРепозитория;
	Перем ИмяПользователяКоторомуПредоставляетсяДоступ;
	
	ИмяОорганизацииИлиПользователя = Валидация.ЗначениеПоТипу(Владелец, "ОрганизацияGitHub");
	ИмяРепозитория = Валидация.ЗначениеПоТипу(Репозиторий, "РепозиторийGitHub");
	ИмяПользователяКоторомуПредоставляетсяДоступ = Валидация.ЗначениеПоТипу(КомуПредоставитьДоступ, "ПользовательGitHub");

	СсылкаЗапроса = СтрШаблон("/repos/%1/%2/collaborators/%3?permission=push", 
					ИмяОорганизацииИлиПользователя, ИмяРепозитория, ИмяПользователяКоторомуПредоставляетсяДоступ);
	Ответ = КоннекторHTTP.Put(Сервер + СсылкаЗапроса, , , Новый Структура("Заголовки", Заголовки()));

	Результат = Новый Структура;
	Если Ответ.КодСостояния = 201 Тогда
		Результат.Вставить("ЕстьОшибки", Ложь);
		Результат.Вставить("Инфо", "Доступ предоставлен");
		Результат.Вставить("КодСостояния", 201);
		Результат.Вставить("ОтветОтСервера", Ответ.Текст());
	ИначеЕсли Ответ.КодСостояния = 204 Тогда
		Результат.Вставить("ЕстьОшибки", Ложь);
		Результат.Вставить("Инфо", "Доступ уже был получен ранее");
		Результат.Вставить("КодСостояния", 204);
		Результат.Вставить("ОтветОтСервера", Ответ.Текст());
	Иначе
		Результат.Вставить("ЕстьОшибки", Истина);
		Результат.Вставить("Инфо", "Неизвестная ошибка. Смотри ОтветОтСервера");
		Результат.Вставить("КодСостояния", Ответ.КодСостояния);
		Результат.Вставить("ОтветОтСервера", Ответ.Текст());
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция Заголовки()
	ЗаголовкиЗапроса = Новый Соответствие;
	ЗаголовкиЗапроса.Вставить("Accept", СтрШаблон("application/vnd.github.v%1+json", ВерсияAPI));
	ЗаголовкиЗапроса.Вставить("User-Agent", "oscript-githubapi");
	ЗаголовкиЗапроса.Вставить("Authorization", СтрШаблон("token %1", ТокенАвторизации));


	Возврат ЗаголовкиЗапроса;
КонецФункции

ТокенАвторизации = "";
ВерсияAPI = "3";

Сервер = "https://api.github.com";