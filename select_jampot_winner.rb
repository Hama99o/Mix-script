class SelectJampotWinner
  include Sidekiq::Worker

  private

  def winner_push(user_id)
    state_machine = StateMachine.find(317)

    push =  push = Push.create!(
      name: state_machine.name,
      workflow_state: state_machine.start_state,
      template: push_template(state_machine.start_state),
      publish_datetime: Time.now,
      user_ids: [user_id],
    )
    scheduled_push(push, [user_id])
  end

  def losers_push(user_ids)
    state_machine = StateMachine.find(322)

    push = push = Push.create!(
      name: state_machine.name,
      workflow_state: state_machine.start_state,
      template: push_template(state_machine.start_state),
      publish_datetime: Time.now,
      user_ids: user_ids,
    )
    scheduled_push(push, user_ids)
  end

  def notify_winner_user_id_on_slack(user_id)
    SlackNotificationWorker.perform_async(
      "The winner user_id is #{user_id}",
      {
        channel: '#jampot',
      }
    )
  end

  def notify_error_on_slack
    SlackNotificationWorker.perform_async(
      "Jampot failed! qualified users not found",
      {
        channel: '#jampot',
      }
    )
  end

  def push_template(state)
    MessengerBot::Wordings.instance.load! # for relaoding the wording
    template = {}
    template[state] = MessengerBot::Wordings.get(state)
    template
  end
end
