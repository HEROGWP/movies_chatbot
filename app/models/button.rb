class Button < ApplicationRecord
  def self.data(question, buttons)
    {
      type: 'template',
      payload: {
        template_type: 'button',
        text: question,
        buttons: buttons.map{|button| { type: 'postback', title: button, payload: button }},
      }
    }
  end
end
