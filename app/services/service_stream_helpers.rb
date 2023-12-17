module ServiceStreamHelpers
  def turbo_stream_action(action, target:, partial:, locals: {})
    # Tried to use turbo_stream.update but it struggles w/ `host` context during rendering being outside of a controller
    # ApplicationController.render works just fine though, so using that here and pushing in as plaintext
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
