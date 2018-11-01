create or replace package simple_log as

  /* Функция формирования строки для логирования путем конкатенации строк через разделитель
   * Разделитель добляется только если строка которую хотели добавить не null
   * При передаче true в параметр force_add_separator, разделитель
   * будет добавлен в любом случае. Это нужно когда ожидается жесткий порядок значений в строке
   * Функция возвращает строку размером до 4000 байт для использования в sql, например, при записи лога в таблицу
   */
  function form_message(cur_message in varchar2,
                        add_text    in varchar2,
                        separator   in varchar2 := ', ',
                        force_add_separator in boolean := false)
  return varchar2;

  /* Функция формирования строки для логирования путем конкатенации строк через разделитель
   * Разделитель добляется только если строка которую хотели добавить не null
   * При передаче true в параметр force_add_separator, разделитель
   * будет добавлен в любом случае, это нужно когда ожидается жесткий порядок значений в строке
   * Функция возвращает строку размером до 32 Кбайт для использования в plsql, например, при
   * выводе лога в аутпут или записи в файл
   */
  function form_message_ext(cur_message in varchar2,
                            add_text    in varchar2,
                            separator   in varchar2 := ', ',
                            force_add_separator in boolean := false)
  return varchar2;

  /* перегруженные функции для приведения переменных базовых типов к строке
   * По умолчанию или при передаче true параметру print_null
   * null значение подменяется строкой 'null'
   */
  function p (str_value  in varchar2,
              print_null in boolean := true)
  return varchar2;

  function p (bool_value in boolean,
              print_null in boolean := true)
  return varchar2;

  function p (num_value  in number,
              print_null in boolean := true)
  return varchar2;

  function p (date_value in date,
              print_null in boolean := true)
  return varchar2;

  /* перегруженные функции-обёртки для вызова из select-выражений
   * так как в sql нельзя передать тип boolean
   * Для отключения замены null на строковое 'null' нужно передать в print_null
   * любую строку отличную от 'true'.
   * Регистр 'true' не важен, если эта замена все же нужна при использовании этого варианта функций
   */
  function p (str_value  in varchar2,
              print_null in varchar2)
  return varchar2;

  function p (num_value  in number,
              print_null in varchar2)
  return varchar2;

  function p (date_value in date,
              print_null in varchar2)
  return varchar2;

end simple_log;
/
show errors

create or replace package body simple_log as

  null_str constant varchar2(10) := 'null';

  /* Функция формирования строки для логирования путем конкатенации строк через разделитель
   * Разделитель добляется только если строка которую хотели добавить не null
   * При передаче true в параметр force_add_separator, разделитель
   * будет добавлен в любом случае. Это нужно когда ожидается жесткий порядок значений в строке
   * Функция возвращает строку размером до 4000 байт для использования в sql, например, при записи лога в таблицу
   */
  function form_message(cur_message in varchar2,
                        add_text    in varchar2,
                        separator   in varchar2 := ', ',
                        force_add_separator in boolean := false)
  return varchar2
  is
    -- предупреждение: сабстр может не помочь при передаче клоба
    result varchar2(4000) := substr(cur_message, 1, 4000);
  begin
    if (add_text is not null) or (force_add_separator) then
      if cur_message is not null then
        result := substr(result || separator, 1, 4000);
      end if;
      result := substr(result || add_text, 1, 4000);
    end if;

    return result;

  end form_message;

  /* Функция формирования строки для логирования путем конкатенации строк через разделитель
   * Разделитель добляется только если строка которую хотели добавить не null
   * При передаче true в параметр force_add_separator, разделитель
   * будет добавлен в любом случае, это нужно когда ожидается жесткий порядок значений в строке
   * Функция возвращает строку размером до 32 Кбайт для использования в plsql, например, при
   * выводе лога в аутпут или записи в файл
   */
  function form_message_ext(cur_message in varchar2,
                            add_text    in varchar2,
                            separator   in varchar2 := ', ',
                            force_add_separator in boolean := false)
  return varchar2
  is
    result varchar2(32767) := cur_message;
  begin
    if (add_text is not null) or (force_add_separator) then
      if cur_message is not null then
        result := substr(result || separator, 1, 32767);
      end if;
      result := substr(result || add_text, 1, 32767);
    end if;

    return result;

  end form_message_ext;

  /* перегруженные функции для приведения переменных базовых типов к строке
   * По умолчанию или при передаче true параметру print_null
   * null значение подменяется строкой 'null'
   */
  function p (str_value  in varchar2,
              print_null in boolean := true)
  return varchar2
  is
  begin
    if print_null then
      return nvl(str_value, null_str);
    end if;

    return str_value;

  end p;

  function p (bool_value in boolean,
              print_null in boolean := true)
  return varchar2
  is
   result varchar2(10);
  begin
    if bool_value is null then
      if print_null then
        result := null_str;
      end if;
    elsif bool_value then
      result := 'true';
    else
      result := 'false';
    end if;

    return result;

  end p;

  function p (num_value  in number,
              print_null in boolean := true)
  return varchar2
  is
  begin
    if print_null then
      return nvl(to_char(num_value), null_str);
    end if;

    return to_char(num_value);

  end p;

  function p (date_value in date,
              print_null in boolean := true)
  return varchar2
  is
   result varchar2(30);
  begin
    if date_value is null then
      if print_null then
        result := 'null';
      end if;
    elsif date_value = trunc(date_value, 'dd') then
      result := to_char(date_value, 'dd/mm/yyyy');
    else
      result := to_char(date_value, 'dd/mm/yyyy hh24:mi:ss');
    end if;

    return result;

end p;


  /* перегруженные функции-обёртки для вызова из select-выражений
   * так как в sql нет типа boolean
   * Для отключения замены null на строковое 'null' нужно передать в print_null
   * любую строку отличную от 'true'.
   * Регистр 'true' не важен, если эта замена все же нужна при использовании этого варианта функций
   */
  function p (str_value  in varchar2,
              print_null in varchar2)
  return varchar2
  is
  begin
    return p (str_value, lower(print_null)='true');
  end p;

  function p (num_value  in number,
              print_null in varchar2)
  return varchar2
  is
  begin
    return p (num_value, lower(print_null)='true');
  end p;

  function p (date_value in date,
              print_null in varchar2)
  return varchar2
  is
  begin
    return p (date_value, lower(print_null)='true');
  end p;

end simple_log;
/
show errors
