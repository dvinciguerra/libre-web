"use strict"

# requires
PageBase        = require 'pages/base.coffee'

# models
AuthModel      = require 'models/auth'

# views/components
Button          = require 'views/button'


###
#  Page class
#  @author dvinciguerra
###
module.exports = class SigninPage extends PageBase
  el: document.body
  template: false

  # templates
  templates:
    message: require 'templates/message'
    input_message: require 'templates/input_message'

  # model
  model: new AuthModel

  # ui elements
  ui:
    main: 'form#login-form'

  # events
  events:
    'submit @ui.main': 'onSubmitLoginForm'
    'change input, radio, checkbox': 'changeFormFields'


  # update model when input changes
  changeFormFields: (event) ->
    event.preventDefault()
    field = event.currentTarget
    @model.set field.id, field.value


  # submit login form action
  onSubmitLoginForm: (event) ->
    event.preventDefault()

    # on invalid event
    unless @model.isValid()
      @clearMessages()
      if @model.errors? and _.has(@model.errors, 'form_error')
        @renderInputMessages($(event.currentTarget), @model.errors.form_error)
      return false

    # submit button
    btn = new Button el: @getUI('main').find('input[type=submit]')
    btn.state 'loading'

    # make user authentication
    params = @model.toJSON()

    @model.authenticate params
      .then (response, status, xhr) =>
        @clearMessages()
        @renderMessage btn.$el.parent(), {
          type: 'success'
          title: 'Bem vindo!'
          message: 'Usuário autênticado...'
        }

        @session.set response if _.isObject response
        setInterval ( -> document.location = '/app'), 250

      .fail (xhr, status) =>
        @clearMessages()
        @renderMessage btn.$el.parent(), {
          type: 'danger'
          title: 'Erro!'
          message: 'Usuário ou senha inválidos'
        }

      .always ->
        btn.state 'loaded'

  # render message
  renderMessage: ($root = null, stash = {}) ->
    # reset messages
    @$el.find('.message').remove()
    rendered = @templates.message(stash)
    $root.append(rendered) if $root?
    rendered


  renderInputMessages: ($root = null, stash = {}) ->
    # reset messages
    @$el.find('small.input-message').remove()
    @$el.find('.has-error').toggleClass('has-error')

    for key, value of stash
      if el = $root.find("[name=#{key}]")
        el.parent().addClass 'has-error'
          .append @templates.input_message({
            content: "#{el.attr('placeholder')} #{@errorList(value)}"
          })


  clearMessages: ->
    @$el.find('.message').remove()
    @$el.find('small.error-message').remove()
    @$el.find('.has-error').toggleClass('has-error')
    return

