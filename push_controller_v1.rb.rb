require 'json'

require 'messenger_bot/application_controller'
require 'messenger_bot/send_push_messages_worker'
require 'messenger_bot/utils'
require 'messenger_bot/utils/read_only_sql_request'

class MessengerBot::V1::PushesController < MessengerBot::ApplicationController
  include PaginationHelper
  attr_reader :push

  before_action :build_push, only: :create

  def index
    per =  params[:per].try(:to_i) || 30
    page = params[:page].try(:to_i)  || 0
    search = params[:search]

    pushes = pushes(search)
    nb_pages = per ? nb_pages(pushes, per) : nil
    pushes = paginated_object(pushes, page, per)
    meta = {
      page: page,
      per: per,
      nb_pages: nb_pages,
      search: search
    }
    render json: pushes,
      meta: meta,
      status: :ok
  end

  def show
    render json: ::Push.where(user_made: true).find(params[:id]),
      status: :ok
  end

  def create
    if all_users_present?
      user_ids = users.blank? ? nil : users.map { |u| u.id }

      if time_schedule.present?
        MessengerBot::SendPushMessagesWorker.perform_at(time_schedule, push.id, user_ids, nil, sql)
      else
        MessengerBot::SendPushMessagesWorker.perform_async(push.id, user_ids, nil, sql)
      end

      notify_push_on_slack

      render json: {
        push: extract_serializer("PushSerializer").new(push),
        count: users.count,
      }, status: :ok
    elsif !all_users_present?
      render json: { "user_ids" => ["some doesn\'t exist"] }, status: :unprocessable_entity
    elsif push.errors.present?
      render json: push.errors, status: :unprocessable_entity
    elsif users.blank?
      render json: { "user_ids" => ['user_ids can\'t be blank'] }, status: :unprocessable_entity
    else
      render json: push.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if push = ::Push.find(params[:id])
      push.destroy
    end
  end

  private

  def pushes(search)
    pushes = ::Push.where(user_made: true).order(created_at: :desc)

    if search
      pushes = pushes.where("name ILIKE :search OR workflow_state ILIKE :search", search: "%#{params[:search]}%")
    end

    pushes
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
      :sql
    ).merge(
      driver_extra_payload,
    ).merge(
      vars: {},
    ).merge(
      user_made: true,
      subscription_id: params[:push][:subscription_id] ?  params[:push][:subscription_id] : 25
    )
  end

  def users
    @users ||= ::User.where(id: user_ids)
  end

  def all_users_present?
    users.present? && user_ids.length == users.length
  end

  def user_ids
    @user_ids ||= params[:push][:user_ids].try(:map) { |id| id.to_i } ||
      users_from_one_time_notification_ids ||
      []
  end

  def users_from_one_time_notification_ids
    @users_from_one_time_notification_ids ||= begin
      if one_time_notification_token.present?
        FacebookOneTimeNotificationToken.where(
          postback: one_time_notification_token,
        ).pluck(:user_id)
      end
    end
  end

  def sql
    params[:push][:sql]
  end

  def one_time_notification_token
    params[:push][:one_time_notification_token]
  end

  def sql_valid?
    begin
      first_result = MessengerBot::Utils::ReadOnlySqlRequest.new(sql).perform[0]

      first_result['user_id'].present? ||
        first_result['id'].present?
    rescue => error
      false
    end
  end


  def sql_error
    begin
      first_result = MessengerBot::Utils::ReadOnlySqlRequest.new(sql).perform[0]

      first_result['user_id'].present? ||
        first_result['id'].present?
    rescue => error
      error.message
    end
  end

  def users_count
    if user_ids.present?
      user_ids.count
    elsif sql.present?
      begin
        MessengerBot::Utils::ReadOnlySqlRequest.new(sql).perform do |row|
          row['user_id'] || row['id']
        end.uniq.count
      rescue
        -1
      end
    else
      -1
    end
  end

  def time_schedule
    if params[:push][:timestamp]
      params[:push][:timestamp].to_i
    elsif params[:push][:publish_datetime]
      Time.zone.parse(params[:push][:publish_datetime]).to_i
    else
      nil
    end
  end

  def slack_message
    if time_schedule
      "[PUSH] Push ##{push.id} '#{push.name}' scheduled at #{Time.at(time_schedule).to_s} for #{users_count} users\n\nTemplate: \n```\n#{pretty_hash(push.template)}\n```\n"
    else
      "[PUSH] Push ##{push.id} '#{push.name}' sent to #{users_count} users\n\nTemplate: \n```\n#{pretty_hash(push.template)}\n```\n"
    end
  end

  def pretty_hash(hash)
    JSON.pretty_generate(hash).gsub(":", " =>")
  end

  def build_push
    @push = ::Push.new(push_create_params)
  end

  def driver_extra_payload
    if facebook_driver?
      {
        facebook_persona_id: params[:push][:persona_id],
      }
    else
      {}
    end
  end

  def facebook_driver?
    MessengerBot::Core.driver == 'facebook'
  end

  def notify_push_on_slack
    SlackNotificationWorker.perform_async(slack_message, {
      "channel" => "C4U8WM51D",
    }) unless ENV['JAM_RELEASE'] == 'alpha'
  end
end
