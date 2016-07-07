# frozen_string_literal: true
class GetAndApplyNewTranslationWorker
  include Sidekiq::Worker

  # TODO: reindex connected offers if a category translation was updated
  def perform gengo_order_id
    gengo_order = GengoOrder.find(gengo_order_id)
    order = GengoCommunicator.new.fetch_order gengo_order.order_id

    # ignore unfinished orders (total_job_count != approved_jobs_count)
    return unless order['total_jobs'].to_i == order['jobs_approved'].count

    updated_model = order['jobs_approved'].map do |job_id|
      get_and_apply_translation_job job_id.to_i, gengo_order.expected_slug
    end.uniq.first

    # reindex affected offers if category translation was updated
    if updated_model.class == Category
      updated_model.self_and_descendants.find_each.map do |category|
        category.offers.approved.each(&:index!)
      end
    end

    # delete gengo_order
    gengo_order.delete
  end

  private

  def get_and_apply_translation_job job_id, expected_slug
    job = GengoCommunicator.new.fetch_job job_id

    # safety mechanism: gengo-slug must match the expected value
    raise 'invalid slug' if job['slug'] != "#{expected_slug}_#{job['lc_tgt']}"

    model, id, field = job['slug'].split(':')
    translated_instance = model.constantize.find(id)
    translation = job['body_tgt']

    translated_instance.send("#{field}=", translation)
    translated_instance.save!

    # return updated model instance ()
    translated_instance
  end
end
