begin;

alter table public.class_student_grades
  add column slogan_life numeric(5, 2) check (slogan_life between 0 and 1),
  add column slogan_business numeric(5, 2)
    check (slogan_business between 0 and 1),
  add column growth_plan_table numeric(5, 2)
    check (growth_plan_table between 0 and 5),
  add column growth_plan_class_improvement numeric(5, 2)
    check (growth_plan_class_improvement between 0 and 5),
  add column products_table numeric(5, 2) check (products_table between 0 and 3),
  add column products_new numeric(5, 2) check (products_new between 0 and 4),
  add column products_presentation numeric(5, 2)
    check (products_presentation between 0 and 10),
  add column business_17_table numeric(5, 2)
    check (business_17_table between 0 and 3),
  add column business_17_quality numeric(5, 2)
    check (business_17_quality between 0 and 4),
  add column business_17_presentation numeric(5, 2)
    check (business_17_presentation between 0 and 10),
  add column book_presentation numeric(5, 2)
    check (book_presentation between 0 and 10),
  add column book_sentences numeric(5, 2)
    check (book_sentences between 0 and 3),
  add column book_question numeric(5, 2) check (book_question between 0 and 1),
  add column talent_test numeric(5, 2) check (talent_test between 0 and 3),
  add column talent_intelligence numeric(5, 2)
    check (talent_intelligence between 0 and 1),
  add column business_6_trader numeric(5, 2)
    check (business_6_trader between 0 and 3),
  add column business_6_related numeric(5, 2)
    check (business_6_related between 0 and 3),
  add column extracurricular numeric
    check (extracurricular >= 0),
  add column participation_sessions jsonb
    check (
      participation_sessions is null
      or jsonb_typeof(participation_sessions) = 'array'
    );

create or replace function public.validate_class_student_grade_details()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
declare
  entry jsonb;
  date_value text;
  parsed_date date;
  score_value numeric;
  participation_total numeric := 0;
  seen_dates date[] := array[]::date[];
begin
  if new.participation_sessions is null then
    return new;
  end if;

  if jsonb_typeof(new.participation_sessions) is distinct from 'array' then
    raise exception 'Participation sessions must be a JSON array.'
      using errcode = '23514';
  end if;

  for entry in
    select value
    from jsonb_array_elements(new.participation_sessions) as session(value)
  loop
    if jsonb_typeof(entry) is distinct from 'object' then
      raise exception 'Each participation session must be an object.'
        using errcode = '23514';
    end if;

    date_value := entry ->> 'date';
    if date_value is null or date_value !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then
      raise exception 'Participation dates must use YYYY-MM-DD format.'
        using errcode = '23514';
    end if;

    begin
      parsed_date := date_value::date;
    exception
      when others then
        raise exception 'Invalid participation date: %.', date_value
          using errcode = '23514';
    end;

    if parsed_date::text <> date_value then
      raise exception 'Invalid participation date: %.', date_value
        using errcode = '23514';
    end if;

    if parsed_date = any(seen_dates) then
      raise exception 'Only one participation score is allowed per date.'
        using errcode = '23514';
    end if;
    seen_dates := array_append(seen_dates, parsed_date);

    if jsonb_typeof(entry -> 'score') is distinct from 'number' then
      raise exception 'Participation scores must be numbers.'
        using errcode = '23514';
    end if;

    score_value := (entry ->> 'score')::numeric;
    if score_value < 0 then
      raise exception 'Participation scores cannot be negative.'
        using errcode = '23514';
    end if;

    participation_total := participation_total + score_value;
    if participation_total > 20 then
      raise exception 'Participation scores cannot total more than 20.'
        using errcode = '23514';
    end if;
  end loop;

  return new;
end;
$function$;

revoke all on function public.validate_class_student_grade_details()
  from public, anon, authenticated;

create trigger validate_class_student_grade_details_before_save
before insert or update of participation_sessions on public.class_student_grades
for each row
execute function public.validate_class_student_grade_details();

notify pgrst, 'reload schema';

commit;
