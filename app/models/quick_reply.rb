class QuickReply < Array
  def initialize(*args)
    super args.flatten.map { |reply| build(reply) }
  end

  protected

  def build(reply)
    {
      content_type: :text,
      title: reply,
      payload: reply
    }
  end
end
