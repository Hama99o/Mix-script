(select distinct count(*)
from users
join subscriptions_users on subscriptions_users.user_id = users.id
where active_at > now() - interval '3 month'
and push is TRUE and message_retry_count < 5 -- pushables et non bloqués
and subscriptions_users.subscription_id in (30, 40, 18)
and (morning_push_hour < 15.5*3600 OR morning_push_hour > 17.5*3600) -- 16h30
and team = false
and age between 15 and 25
and gender is not null
and city_id = 30438
) --1,708