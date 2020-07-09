create or replace package pl as

  /* Перегруженные функции для приведения переменных базовых типов к строке
   * По умолчанию или при передаче true параметру print_null null-значения подменяются на строку 'null'
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

  /* Функция формирования строки для логирования путем конкатенации строк через разделитель
   * Разделитель добляется только если строка которую хотели добавить не null
   * При передаче true в параметр force_add_separator, разделитель  будет добавлен в любом случае.
   * Это может быть нужно когда ожидается жесткий порядок значений в строке
   * Параметром limit_length регулируется максимальная длина возвращаемой строки
   */
  function fm( cur_message   in varchar2,
               add_text      in varchar2,
               separator     in varchar2 := ', ',
               force_add_sep in boolean := false,
               limit_length  in integer := 32767 )
  return varchar2;

  procedure fm( cur_message   in out varchar2,
                add_text      in     varchar2,
                separator     in     varchar2 := ', ',
                force_add_sep in     boolean := false,
                limit_length  in     integer := 32767 );

end pl;
/
show errors


create or replace package body pl as

  null_str constant varchar2(5 char) := 'null';

  /* Перегруженные функции для приведения переменных базовых типов к строке
   * По умолчанию или при передаче true параметру print_null null-значения подменяются на строку 'null'
   */
  function p( str_value  in varchar2,
              print_null in boolean := true )
  return varchar2
  is
  begin
    if print_null then
      return nvl(str_value, null_str);
    end if;

    return str_value;
  end p;

  function p( bool_value in boolean,
              print_null in boolean := true )
  return varchar2
  is
   result varchar2(6 char);
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

  function p( num_value  in number,
              print_null in boolean := true )
  return varchar2
  is
  begin
    if print_null then
      return nvl(to_char(num_value), null_str);
    end if;

    return to_char(num_value);
  end p;

  function p( date_value in date,
              print_null in boolean := true )
  return varchar2
  is
    result varchar2(100);
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

  /* Функция формирования строки для логирования путем конкатенации строк через разделитель
   * Разделитель добляется только если строка которую хотели добавить не null
   * При передаче true в параметр force_add_separator, разделитель  будет добавлен в любом случае.
   * Это может быть нужно когда ожидается жесткий порядок значений в строке
   * Параметром limit_length регулируется максимальная длина возвращаемой строки
   */
  function fm( cur_message   in varchar2,
               add_text      in varchar2,
               separator     in varchar2 := ', ',
               force_add_sep in boolean := false,
               limit_length  in integer := 32767 )
  return varchar2
  is
    limit  integer         := limit_length;
    result varchar2(32767) := cur_message;
  begin
    if limit is null or limit <= 0 or limit > 32767 then
      limit := 32767;
    end if;

    if force_add_sep or add_text is not null then
      if cur_message is not null or force_add_sep then
        result := result || separator || add_text;
      else
        result := result || add_text;
      end if;
    end if;

    return substr(result, 1, limit);
  end fm;

  procedure fm( cur_message   in out varchar2,
                add_text      in     varchar2,
                separator     in     varchar2 := ', ',
                force_add_sep in     boolean := false,
                limit_length  in     integer := 32767 )
  is
  begin
    cur_message := fm(cur_message, add_text, separator, force_add_sep, limit_length);
  end;

end pl;
/
show errors

