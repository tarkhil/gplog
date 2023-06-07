-- Я не уверен в эффективности поиска по такой конструкции
-- Впрочем, на тысяче строк ничего осмысленного сказать все равно нельзя
create view combined as (
  select l.created, l.str, l.int_id, l.address from log l
   union
  select m.created, m.str, m.int_id, l.address
    from message m join log l on l.int_id = m.int_id
);
