-- note: file encoding: cp-1251

create or replace package simple_log as

  /* ������� ������������ ������ ��� ����������� ����� ������������ ����� ����� �����������
   * ����������� ��������� ������ ���� ������ ������� ������ �������� �� null
   * ��� �������� true � �������� force_add_separator, �����������
   * ����� �������� � ����� ������. ��� ����� ����� ��������� ������� ������� �������� � ������
   * ������� ���������� ������ �������� �� 4000 ���� ��� ������������� � sql, ��������, ��� ������ ���� � �������
   */
  function form_message(cur_message in varchar2,
                        add_text    in varchar2,
                        separator   in varchar2 := ', ',
                        force_add_separator in boolean := false)
  return varchar2;

  /* ������� ������������ ������ ��� ����������� ����� ������������ ����� ����� �����������
   * ����������� ��������� ������ ���� ������ ������� ������ �������� �� null
   * ��� �������� true � �������� force_add_separator, �����������
   * ����� �������� � ����� ������, ��� ����� ����� ��������� ������� ������� �������� � ������
   * ������� ���������� ������ �������� �� 32 ����� ��� ������������� � plsql, ��������, ���
   * ������ ���� � ������ ��� ������ � ����
   */
  function form_message_ext(cur_message in varchar2,
                            add_text    in varchar2,
                            separator   in varchar2 := ', ',
                            force_add_separator in boolean := false)
  return varchar2;

  /* ������������� ������� ��� ���������� ���������� ������� ����� � ������
   * �� ��������� ��� ��� �������� true ��������� print_null
   * null �������� ����������� ������� 'null'
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

  /* ������������� �������-������ ��� ������ �� select-���������
   * ��� ��� � sql ������ �������� ��� boolean
   * ��� ���������� ������ null �� ��������� 'null' ����� �������� � print_null
   * ����� ������ �������� �� 'true'.
   * ������� 'true' �� �����, ���� ��� ������ ��� �� ����� ��� ������������� ����� �������� �������
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

  /* ������� ������������ ������ ��� ����������� ����� ������������ ����� ����� �����������
   * ����������� ��������� ������ ���� ������ ������� ������ �������� �� null
   * ��� �������� true � �������� force_add_separator, �����������
   * ����� �������� � ����� ������. ��� ����� ����� ��������� ������� ������� �������� � ������
   * ������� ���������� ������ �������� �� 4000 ���� ��� ������������� � sql, ��������, ��� ������ ���� � �������
   */
  function form_message(cur_message in varchar2,
                        add_text    in varchar2,
                        separator   in varchar2 := ', ',
                        force_add_separator in boolean := false)
  return varchar2
  is
    -- ��������������: ������ ����� �� ������ ��� �������� �����
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

  /* ������� ������������ ������ ��� ����������� ����� ������������ ����� ����� �����������
   * ����������� ��������� ������ ���� ������ ������� ������ �������� �� null
   * ��� �������� true � �������� force_add_separator, �����������
   * ����� �������� � ����� ������, ��� ����� ����� ��������� ������� ������� �������� � ������
   * ������� ���������� ������ �������� �� 32 ����� ��� ������������� � plsql, ��������, ���
   * ������ ���� � ������ ��� ������ � ����
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

  /* ������������� ������� ��� ���������� ���������� ������� ����� � ������
   * �� ��������� ��� ��� �������� true ��������� print_null
   * null �������� ����������� ������� 'null'
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


  /* ������������� �������-������ ��� ������ �� select-���������
   * ��� ��� � sql ��� ���� boolean
   * ��� ���������� ������ null �� ��������� 'null' ����� �������� � print_null
   * ����� ������ �������� �� 'true'.
   * ������� 'true' �� �����, ���� ��� ������ ��� �� ����� ��� ������������� ����� �������� �������
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
