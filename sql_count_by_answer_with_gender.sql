select
    count(message_id) as "count",
    sum(case when users.gender = 'male' then 1 else 0 end) male,
    sum(case when users.gender = 'female' then 1 else 0 end) female,    
    answers.text as "text"
from
    answers
INNER JOIN users ON users.id = answers.user_id
where
    answers.question_id = 100
    and answers.kind is null
group by "text"