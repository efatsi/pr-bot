module ServiceStreamHelpers
  # This helper method generates the turbo html that's handled by `Turbo.renderStreamMessage`
  #
  # Tried to use regular `turbo_stream.update` but it struggles w/ `host` context during rendering
  # due to this being outside of a controller request/response
  #
  # ApplicationController.render works just fine though so using that here and pushing
  # the results in as plaintext.
  def turbo_stream_action(action, target:, partial:, locals: {})
    turbo_stream.send(
      action,
      target,
      plain: ApplicationController.render(partial: partial, locals: locals)
    )
  end

  def turbo_stream
    @turbo_stream ||= ApplicationController.new.view_context.turbo_stream
  end
end
