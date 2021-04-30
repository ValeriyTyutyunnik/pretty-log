pl
===============

pl [pretty_log] - PL/SQL package that allows simplify prepearing data for logging, which means to reduce development time, increase code readability and reduce code amount.
Package functions perform 2 main tasks:
1. A unified interface for converting variables of basic types to string. Variables with null value returns as 'null' string (may be changed by parameter)
2. Forming message (for log) variable by appening values through a separator. This is usefull when it is no possible to form a complite strings at ones (like cycles)

Examples
=================

1) Get error message with all procedure parametes:
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
  /*  some code here that throws error */
exception
  when others then
    logger.log(location => 'some_proc',
               errm => sqlerrm(sqlcode)
               params => 'var_int1=' || pl.p(var_int1) ||
                         ', var_int2=' || pl.p(var_int2) ||
                         ', var_int3=' || pl.p(var_int3) ||
                         ', var_date1=' || pl.p(var_date1) ||
                         ', var_date2=' || pl.p(var_date2) ||
                         ', var_str1=' || pl.p(var_str1) ||
                         ', var_str2=' || pl.p(var_str2) ||
                         ', var_bool=' || pl.p(var_bool)
              );
    raise_application_error(-20001, 'Error in some_proc [params: var_int1='||pl.p(var_int1) ||
                            ' var_int2='||pl.p(var_int2)||' var_int3='||pl.p(var_int3) ||
                            ' var_date1='||pl.p(var_date1)||' var_date2='||pl.p(var_date2) ||
                            ' var_str1='||pl.p(var_str1)||' var_str2='||pl.p(var_str2) ||
                            ' var_bool='||pl.p(var_bool)||'] ' || sqlerrm(sqlcode));
end some_proc;
```

For call proc with this kind of values that:
```
exec some_proc(100500, 1, null, current_date, trunc(sysdate, 'mm'), null, 'str', false);
```

In case of buffer overflow there will be raised exception with this text:
```
ORA-20001: Error in some_proc [params: var_int1=100500, var_int2=1, var_int3=null, var_date1=31.10.2018 19:59:53, var_date2=01.10.2018 00.00.00, var_str1=, var_str2=str, var_bool=false] ORA-06502: PL/SQL: numeric or value error: character string buffer too small
```

2) Print list of all collection elements:
```
declare
  type str_table is table of varchar2(10) index by pls_integer;
  numbers_arr str_table;
  log_message varchar2(4000);
begin
  numbers_arr(1) := 'one';
  numbers_arr(2) := 'two';
  numbers_arr(3) := 'tree';
  numbers_arr(4) := null;
  numbers_arr(7) := 'seven';

  for i in numbers_arr.first .. numbers_arr.last
  loop
    if numbers_arr.exists(i) then
      log_message := pl.fm(log_message, i||'='||numbers_arr(i), '; ');
    end if;
  end loop;

  dbms_output.put_line(log_message);
end;
```
Result:
```
1=one; 2=two; 3=tree; 4=null; 7=seven
```
