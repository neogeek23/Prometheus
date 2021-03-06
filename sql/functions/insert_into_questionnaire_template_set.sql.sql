create OR REPLACE function insert_into_questionnaire_template_set(questionnaire_template bigint, version SMALLINT, content bigint, before_questionnaire_template_set bigint)
  returns void
as $$
declare
  following_order INTEGER;
  new_questionnaire_template_set bigint;
  prior_questionnaire_template_set bigint;
begin
  following_order := (select order_index from questionnaire_template_set where questionnaire_template_set_id=before_questionnaire_template_set);
  update questionnaire_template_set set order_index = order_index + 1 where questionnaire_template_id = questionnaire_template and template_set_version = version and order_index >= following_order;
  insert into questionnaire_template_set (questionnaire_template_id, template_set_version, content_id, next_questionnaire_template_set_id, order_index)
    values (questionnaire_template, version, content, before_questionnaire_template_set, following_order);
  new_questionnaire_template_set := (select questionnaire_template_set_id
                                     from questionnaire_template_set
                                     where next_questionnaire_template_set_id = before_questionnaire_template_set
                                           and template_set_version = version and content_id = content);
  prior_questionnaire_template_set := (select questionnaire_template_set_id
                                       from questionnaire_template_set
                                       where next_questionnaire_template_set_id = before_questionnaire_template_set
                                             and template_set_version = version and order_index = following_order-1);
  update questionnaire_template_set set next_questionnaire_template_set_id=new_questionnaire_template_set where questionnaire_template_set_id=prior_questionnaire_template_set;
end
$$ LANGUAGE plpgsql;
