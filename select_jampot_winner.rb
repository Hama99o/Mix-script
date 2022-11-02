class SelectJampotWinner
  include Sidekiq::Worker

  def perform
    competition_items = CompetitionItem
      .joins(:user)
      .where("
        closed_at is null
        and gender is not null
        and age is not null
        and city_id is not null
        and occupation is not null
      ")

    user_ids_with_scores = {}

    competition_items.find_each do |competition_item|
      user_ids_with_scores[competition_item.user_id] ||= 0
      user_ids_with_scores[competition_item.user_id] += competition_item.score
    end

    if user_ids_with_scores.present?
      winner_user_id = winner_user_id_draw(user_ids_with_scores)
      loser_user_ids = user_ids_with_scores.keys - [winner_user_id]

      winner_push(winner_user_id)
      losers_push(loser_user_ids)
      competition_items.update_all(closed_at: Time.now)
      notify_winner_user_id_on_slack(winner_user_id)
    else
      notify_error_on_slack
      raise StandardError.new "Qualified users not found"
    end
  end

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


  def scheduled_push(push, user_ids)
    MessengerBot::SendPushMessagesWorker.perform_at(push.publish_datetime.to_i, push.id, user_ids, nil, nil)
    push.update(scheduled: true)
  end

  def winner_user_id_draw(user_ids_with_scores)
    max_score = user_ids_with_scores.values.sum

    if max_score >= 1
      random_score = rand(1..max_score)

      user_ids_with_scores.each do |user_id, user_score|
        return user_id if random_score <= user_score
        random_score -= user_score
      end
    end
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
