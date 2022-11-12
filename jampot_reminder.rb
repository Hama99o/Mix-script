class JampotReminder
  include Sidekiq::Worker

  STATE_MACHINE_NAME = "jampot_1j_tirage"

  def perform
    if competition_items.any?
      first_reminder_push!
      second_reminder_push!

      user_count = competition_items.select(:id).distinct.count
      notify_slack("reminder push has been sent to #{user_count} users for jampot")
    end
  end

  def competition_items
    CompetitionItem
    .joins(:user)
    .where("
      competition_items.closed_at is null
      and users.push = true
      and (users.country = 'France' OR users.country is null)
      and users.message_retry_count < 5
      ")
  end

  def first_reminder_push!
    raise "'#{STATE_MACHINE_NAME}' state machine doesn't exist" unless MessengerBot::StateMachine.exists?(STATE_MACHINE_NAME)

    state_machine ||= MessengerBot::StateMachine.instance.find(STATE_MACHINE_NAME)
    sql_query = first_push_users
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

    MessengerBot::SendPushMessagesWorker.perform_at(push.publish_datetime.to_i, push.id, nil, nil, push.sql)
    push.update(scheduled: true)
  end

  def second_reminder_push!
    raise "'#{STATE_MACHINE_NAME}' state machine doesn't exist" unless MessengerBot::StateMachine.exists?(STATE_MACHINE_NAME)

    state_machine ||= MessengerBot::StateMachine.instance.find(STATE_MACHINE_NAME)
    sql_query = second_push_users
      .select(:user_id)
      .distinct
      .to_sql

    publish_datetime = Time.now + 1.hour + 30.minutes

    push = Push.create!(
      name: "#{state_machine.name}_#{publish_datetime.strftime("%H:%M")}",
      workflow_state: state_machine.start_state,
      template: { state_machine.start_state => MessengerBot::Wordings.get(state_machine.start_state) },
      publish_datetime: publish_datetime,
      sql: sql_query,
    )

    MessengerBot::SendPushMessagesWorker.perform_at(push.publish_datetime.to_i, push.id, nil, nil, push.sql)
    push.update(scheduled: true)
  end

  def notify_slack(text)
    SlackNotificationWorker.perform_async(
     text,
      {
        channel: '#tech-debug-testing',
      }
    )
  end

  def first_push_users
    one_hour_before = (Time.now).strftime("%H:%M").to_i * 3600
    one_hour_after = (Time.now + 1.hour).strftime("%H:%M").to_i * 3600
    competition_items.where("users.morning_push_hour <  #{one_hour_before} OR users.morning_push_hour > #{one_hour_after}")
  end

  def second_push_users
    one_hour_before = (Time.now).strftime("%H:%M").to_i * 3600
    one_hour_after = (Time.now + 1.hour).strftime("%H:%M").to_i * 3600
    competition_items.where("users.morning_push_hour >= #{one_hour_before} AND users.morning_push_hour < #{one_hour_after}")
  end
end
