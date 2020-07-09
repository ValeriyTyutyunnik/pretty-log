pl
===============

pl [pretty_log] - PL/SQL пакет, позволяющий упростить логику подготовки данных для логирования при выполнении pl/sql кода проекта, а значит снизить время на разработку и общий объём кода.
Функции пакета выполняют 2 основные задачи:
1. Приведение данных типов date, number, boolean к типу varchar2 идентичной по вызову функцией. Не требуется выбирать из различных функций подходящую под нужный тип или прописывать каждый раз логику приведения к типу varchar2.
Переменные перечисленных ранее типов (а так же с типом varchar2) со значением null по умолчанию преобразовываются к строке 'null'. Если преобразование не требуется его можно отключить
2. Формирование строковой переменной с данными для логирования. Этот функционал полезен, когда нет возможности сформировать полную строку сразу, но в процессе работы программы требуется время от времени дополнять строку новыми данными с или без разделителя.

С чего начать?
===========

1. Запустите скрипт в вашем экземпляре БД ```@pl.sql``` - произойдёт компиляция пакета.
2. Включить функции пакета в код базы данныx

Примеры использования
=================

1) Допустим в проекте есть некая хранимая процедура (или процедура в пакете). Нам требуется вывести входные параметры в случае ошибки
```
create or replace procedure some_proc(var_int1 integer,
                                      var_int2 number,
                                      var_int3 number,
                                      var_date1 date,
                                      var_date2 date,
                                      var_str1 varchar2,
                                      var_str2 varchar2,
                                      var_bool boolean) is
begin
  /*  some code here */
exception
  when others then
    raise_application_error(-20001, 'Error in some_proc [params: var_int1='||pl.p(var_int1)||
                            ' var_int2='||pl.p(var_int2)||' var_int3='||pl.p(var_int3)||
                            ' var_date1='||pl.p(var_date1)||' var_date2='||pl.p(var_date2)||
                            ' var_str1='||pl.p(var_str1)||' var_str2='||pl.p(var_str2)||
                            ' var_bool='||pl.p(var_bool)||'] '||sqlerrm(sqlcode));
end some_proc;
```

При таком вызове этой процедуры:
```
exec some_proc(100500, 1, null, current_date, trunc(sysdate, 'mm'), null, '', null, false, null);
```

В случае ошибки, пусть это будет переполнение буфера, будет получен такой текст:
```
ORA-20001: Error in some_proc [params: var_int1=100500, var_int2=1, empty_num=null, var_date1=31/10/2018 19:59:53, var_date2=01/10/2018, empty_date=null, var_str1=, empty_str=null, var_bool=false, empty_bool=null] ORA-06502: PL/SQL: numeric or value error: character string buffer too small
```

2) Вывести элементы коллекции одной строкой:
``
declare
  type str_table is table of varchar2(10) index by pls_integer;
  numbers_arr str_table;
  log_message varchar2(4000);
begin
  numbers_arr(1) := 'one';
  numbers_arr(2) := 'two';
  numbers_arr(3) := 'tree';
  numbers_arr(5) := 'five';

  for i in numbers_arr.first .. numbers_arr.last
  loop
    if numbers_arr.exists(i) then
      log_message := pl.fm(log_message, i||'='||numbers_arr(i), '; ');
    end if;
  end loop;

  dbms_output.put_line(log_message);
end;
```
На выходе будет получено:
```
1=one; 2=two; 3=tree; 5=five

