# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    skip_authorization

    latest_threads = ThreadList.recent_public.limit(6).includes(messages: :created_by, issue: :tags).to_a
    @latest_threads = ThreadListDecorator.decorate_collection(latest_threads)
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: latest_threads)

    return unless current_user

    @user_subscriptions = current_user.thread_subscriptions.active.where(thread: latest_threads).to_a
    @user_favourites = current_user.thread_favourites.where(thread: latest_threads).to_a
  end
end
