create or replace package pl as

  /* Override functions "p" - Casts value of basic type to varchar2 and returns string
   * @param value - value to cast
   * @param print_null_str - if true (default) returns null value as string 'null'. Else returns null string
   * @param format - (for dates and number types and their derivatives only) - cast format
   */
  function p (str_value      in varchar2,
              print_null_str in boolean := true)
  return varchar2;

  -- @override
  function p (bool_value     in boolean,
              print_null_str in boolean := true)
  return varchar2;

  -- @override
  function p (num_value      in number,
              format         in varchar2 := null,
              print_null_str in boolean := true)
  return varchar2;

  -- @override
  function p( date_value     in date,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss',
              print_null_str in boolean  := true )
  return varchar2;

  -- @override
  function p( date_value     in timestamp,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss.ff',
              print_null_str in boolean  := true )
  return varchar2;

  -- @override
  function p( date_value     in timestamp with time zone,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss.ff tzh:tzm',
              print_null_str in boolean  := true )
  return varchar2;

  -- @override
  function p( date_value     in timestamp with local time zone,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss.ff',
              print_null_str in boolean  := true )
  return varchar2;

  /* Function for forming a string for logging by concatenating strings through a separator
   * The separator is applied only if value for add is not null
   * @param cur_message - original string to which the value is appended
   * @param add_text - vale to append
   * @param separator - separator for values
   * @param force_add_sepator - if true the separator will be added even value is null
   * @param limit_length - maximum length of the returned string
   */
  function fm( cur_message   in varchar2,
               add_text      in varchar2,
               separator     in varchar2 := ', ',
               force_add_sep in boolean := false,
               limit_length  in integer := 32767 )
  return varchar2;

  -- @override
  procedure fm( cur_message   in out varchar2,
                add_text      in     varchar2,
                separator     in     varchar2 := ', ',
                force_add_sep in     boolean := false,
                limit_length  in     integer := 32767 );

end pl;
/
show errors


create or replace package body pl as

  null_str constant varchar2(4 char) := 'null';

  /* Override functions "p" - Casts value of basic type to varchar2 and returns string
   * @param value - value to cast
   * @param print_null_str - if true (default) returns null value as string 'null'. Else returns null string
   * @param format - (for dates and number types and their derivatives only) - cast format
   */
  function p( str_value      in varchar2,
              print_null_str in boolean := true )
  return varchar2
  is
  begin
    if print_null_str and str_value is null then
      return null_str;
    end if;

    return str_value;
  end p;

  -- @override
  function p( bool_value     in boolean,
              print_null_str in boolean := true )
  return varchar2
  is
   result varchar2(6 char);
  begin
    if bool_value is null then
      if print_null_str then
        result := null_str;
      end if;
    elsif bool_value then
      result := 'true';
    else
      result := 'false';
    end if;

    return result;
  end p;

  -- @override
  function p( num_value      in number,
              format         in varchar2 := null,
              print_null_str in boolean  := true )
  return varchar2
  is
    result varchar2(1000);
  begin
    if num_value is null then
      if print_null_str then
        result := null_str;
      end if;
    elsif format is not null then
      result := to_char(num_value, format);
    else
      result := to_char(num_value);
    end if;

    return result;
  end p;

  -- @override
  function p( date_value     in date,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss',
              print_null_str in boolean  := true )
  return varchar2
  is
    result varchar2(1000);
  begin
    if date_value is null then
      if print_null_str then
        result := null_str;
      end if;
    elsif format is not null then
      result := to_char(date_value, format);
    else
      result := to_char(date_value);
    end if;

    return result;
  end p;

  -- @override
  function p( date_value     in timestamp,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss.ff',
              print_null_str in boolean  := true )
  return varchar2
  is
    result varchar2(1000);
  begin
    if date_value is null then
      if print_null_str then
        result := null_str;
      end if;
    elsif format is not null then
      result := to_char(date_value, format);
    else
      result := to_char(date_value);
    end if;

    return result;
  end p;

  -- @override
  function p( date_value     in timestamp with time zone,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss.ff tzh:tzm',
              print_null_str in boolean  := true )
  return varchar2
  is
    result varchar2(1000);
  begin
    if date_value is null then
      if print_null_str then
        result := null_str;
      end if;
    elsif format is not null then
      result := to_char(date_value, format);
    else
      result := to_char(date_value);
    end if;

    return result;
  end p;

  -- @override
  function p( date_value     in timestamp with local time zone,
              format         in varchar2 := 'dd.mm.yyyy hh24:mi:ss.ff',
              print_null_str in boolean  := true )
  return varchar2
  is
    result varchar2(1000);
  begin
    if date_value is null then
      if print_null_str then
        result := null_str;
      end if;
    elsif format is not null then
      result := to_char(date_value, format);
    else
      result := to_char(date_value);
    end if;

    return result;
  end p;

  /* Function for forming a string for logging by concatenating strings through a separator
   * The separator is applied only if value for add is not null
   * @param cur_message - original string to which the value is appended
   * @param add_text - vale to append
   * @param separator - separator for values
   * @param force_add_sepator - if true the separator will be added even value is null
   * @param limit_length - maximum length of the returned string
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

  -- @override
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

