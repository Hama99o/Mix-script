
class MessengerBot::V2::PushesController < MessengerBot::V1::PushesController
  before_action :get_push, only: [:update, :schedule]
  before_action :build_push, only: :create

  def update
    if @push.update(update_push_params)
      render json: { push: MessengerBot::V2::PushSerializer.new(@push).serializable_hash },
      status: :ok
    else
      render unprocessable_entity(@push)
    end
  end

  def create

    if all_users_present? && @push.save
      render json: {
        push: extract_serializer("PushSerializer").new(@push),
        count: users.count,
      }, status: :ok
    elsif !(users.present? && user_ids.length == users.length)
      p 'byeeeeeeeeeeeeeeee'
      p ' 22222222222222'
      render json: { "user_ids" => ["some doesn\'t exist"] }, status: :unprocessable_entity
    elsif @push.errors.present?
      render json: @push.errors, status: :unprocessable_entity
    elsif users.blank?
      render json: { "user_ids" => ['user_ids can\'t be blank'] }, status: :unprocessable_entity
    else
      render json: @push.errors, status: :unprocessable_entity
    end
  end

  def schedule
    user_ids =  @push.user_ids.present? ? @push.user_ids : nil

    if time_schedule.present?
      MessengerBot::SendPushMessagesWorker.perform_at(time_schedule, @push.id, user_ids, nil, @push.sql)
    else
      MessengerBot::SendPushMessagesWorker.perform_async(@push.id, user_ids, nil, @push.sql)
    end

    notify_push_on_slack

    @push.update({ scheduled: true })
    render json: {
        push: extract_serializer("PushSerializer").new(@push),
        count: users_count,
      },
      status: :ok
  end

  def segment_data
    push_segement_data = PushSegmentData.new(params)

    render json: MessengerBot::PushSegmentDataSerializer.new(push_segement_data).serializable_hash,
    status: :ok
  end

  private

  def users_count
    if @push.user_ids.present?
      @push.user_ids.count
    elsif @push.sql.present?
      begin
        MessengerBot::Utils::ReadOnlySqlRequest.new(@push.sql).perform do |row|
          row['user_id'] || row['id']
        end.uniq.count
      rescue
        -1
      end
    else
      -1
    end
  end

  def push_create_params
    params.require(:push).permit(
      :name,
      :workflow_state,
      :template,
      :sponsored,
      :test,
      :subscription_id,
      :message_tag,
      :one_time_notification_token,
      :publish_datetime,
      :sql,
      :poll_id,
      front_params: {},
      user_ids: []
    ).merge(
      driver_extra_payload,
    ).merge(
      vars: {},
    ).merge(
      user_made: true,
      subscription_id: params[:push][:subscription_id] ?  params[:push][:subscription_id] : 25
    )
  end

  def slack_message
    if time_schedule
      "[PUSH] Push ##{@push.id} '#{@push.name}' scheduled at #{Time.at(time_schedule).to_s} for #{users_count} users\n\nTemplate: \n```\n#{pretty_hash(@push.template)}\n```\n"
    else
      "[PUSH] Push ##{@push.id} '#{@push.name}' sent to #{users_count} users\n\nTemplate: \n```\n#{pretty_hash(@push.template)}\n```\n"
    end
  end

  def time_schedule

    if @push.publish_datetime
      @push.publish_datetime.to_i
    else
      nil
    end
  end

  def get_push
    @push = Push.find(params[:id])
  end

  def update_push_params
    params.require(:push).permit(
      :name,
      :workflow_state,
      :sql,
      :publish_datetime,
      :template,
      :poll_id,
      front_params: {},
      user_ids: []
    )
  end
end

