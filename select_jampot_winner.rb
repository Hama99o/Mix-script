class SelectJampotWinner
  include Sidekiq::Worker

  WINNER_STATE_MACHINE_NAME = "jampot_winner"
  LOSER_STATE_MACHINE_NAME = "jampot_loser"

  def perform
    competition_items = CompetitionItem
      .joins(:user)
      .where("
        competition_items.closed_at is null
        and users.gender is not null
        and users.age is not null
        and users.city_id is not null
        and users.occupation is not null
        and users.team = false
      ")

    score_group_by_user_ids = {}

    competition_items.find_each do |competition_item|
      score_group_by_user_ids[competition_item.user_id] ||= 0
      score_group_by_user_ids[competition_item.user_id] += competition_item.score
    end

    if score_group_by_user_ids.keys.any?
      winner_id = draw_winner_id(score_group_by_user_ids)

      winner_push(winner_id)
      first_loser_push(competition_items.where.not(user_id: winner_id))
      second_loser_push(competition_items.where.not(user_id: winner_id))

      competition_items.update_all(closed_at: Time.now)
      notify_slack("The winner user_id is #{winner_id}")
    else
      notify_slack("Jampot failed! qualified users not found")
      raise ("Qualified users not found")
    end
  end

  def winner_push(winner_id)
    raise "'#{WINNER_STATE_MACHINE_NAME}' state machine doesn't exist" unless MessengerBot::StateMachine.exists?(WINNER_STATE_MACHINE_NAME)

    state_machine ||= MessengerBot::StateMachine.instance.find(WINNER_STATE_MACHINE_NAME)

    push = Push.create!(
      name: "#{state_machine.name}_#{winner_publish_datetime(winner_id).strftime("%H:%M")}",
      workflow_state: state_machine.start_state,
      template: { state_machine.start_state => MessengerBot::Wordings.get(state_machine.start_state) },
      publish_datetime: winner_publish_datetime(winner_id),
      user_ids: [winner_id]
    )

    scheduled_push(push)
  end


  def first_loser_push(competition_items)
    raise "'#{LOSER_STATE_MACHINE_NAME}' state machine doesn't exist" unless MessengerBot::StateMachine.exists?(LOSER_STATE_MACHINE_NAME)

    state_machine ||= MessengerBot::StateMachine.instance.find(LOSER_STATE_MACHINE_NAME)
    sql_query = first_push_users(competition_items)
    .select(:user_id)
    .distinct
    .to_sql

    publish_datetime = Time.now + 30.minutes


    push = Push.create!(
      name: "#{state_machine.name}_#{publish_datetime.strftime("%H:%M")}",
      workflow_state: state_machine.start_state,
      template: { state_machine.start_state => MessengerBot::Wordings.get(state_machine.start_state) },
      publish_datetime: publish_datetime,
      sql: sql_query
    )

    scheduled_push(push)
  end


  def second_loser_push(competition_items)
    raise "'#{LOSER_STATE_MACHINE_NAME}' state machine doesn't exist" unless MessengerBot::StateMachine.exists?(LOSER_STATE_MACHINE_NAME)

    state_machine ||= MessengerBot::StateMachine.instance.find(LOSER_STATE_MACHINE_NAME)
    sql_query = second_push_users(competition_items)
    .select(:user_id)
    .distinct
    .to_sql

    publish_datetime = Time.now + 1.hour + 30.minutes


    push = Push.create!(
      name: "#{state_machine.name}_#{publish_datetime.strftime("%H:%M")}",
      workflow_state: state_machine.start_state,
      template: { state_machine.start_state => MessengerBot::Wordings.get(state_machine.start_state) },
      publish_datetime: publish_datetime,
      sql: sql_query
    )

    scheduled_push(push)
  end

  def scheduled_push(push)
    MessengerBot::SendPushMessagesWorker.perform_at(push.publish_datetime.to_i, push.id, nil, nil, push.sql)
    push.update(scheduled: true)
  end


  def winner_publish_datetime(id)
    one_hour_before = (Time.now).strftime("%H:%M").to_i * 3600
    one_hour_after = (Time.now + 1.hour).strftime("%H:%M").to_i * 3600
    user = User.find(id)
    user.morning_push_hour >= one_hour_before && user.morning_push_hour < one_hour_after ? Time.now + 30.minutes + 1.hour : Time.now + 30.minutes
  end

  def draw_winner_id(score_group_by_user_ids)
    max_score = score_group_by_user_ids.values.sum

    if max_score >= 1
      random_score = rand(1..max_score)

      score_group_by_user_ids.each do |user_id, user_score|
        return user_id if random_score <= user_score
        random_score -= user_score
      end
    end
  end

  def notify_slack(text)
    SlackNotificationWorker.perform_async(
     text,
      {
        channel: '#jampot',
      }
    )
  end

  def push_template(state)
    { state => MessengerBot::Wordings.get(state) }
  end

  def first_push_users(competition_items)
    one_hour_before = (Time.now).strftime("%H:%M").to_i * 3600
    one_hour_after = (Time.now + 1.hour).strftime("%H:%M").to_i * 3600
    competition_items.joins(:user).where("users.morning_push_hour <  #{one_hour_before} OR users.morning_push_hour > #{one_hour_after}")
  end

  def second_push_users(competition_items)
    one_hour_before = (Time.now).strftime("%H:%M").to_i * 3600
    one_hour_after = (Time.now + 1.hour).strftime("%H:%M").to_i * 3600
    competition_items.joins(:user).where("users.morning_push_hour >= #{one_hour_before} AND users.morning_push_hour < #{one_hour_after}")
  end
end
