# requires
PageBase = require 'pages/base.coffee'
ButtonView = require 'views/button.coffee'
SessionModel = require 'models/session.coffee'
SupportModel = require 'models/donor/support.coffee'

I18n = require 'lib/i18n.coffee'
RequestError = require 'lib/exception/request.coffee'


###
#  Page class
#  @author dvinciguerra
###
module.exports = class SigninPage extends PageBase
  el: document.body
  template: false

  model: new SessionModel {type: 'signin'}

  templates:
    message: require 'templates/message'
    input_message: require 'templates/input_message'

  ui:
    form: 'form#login-form'
    button: 'form#login-form input[type=submit]'

  events:
    'submit @ui.form': 'onSubmitLoginForm'
    'click a.js-btn-toogle': 'onClickJSTooglePanels'


  submitButton: ->
    unless @_button?
      @_button = new ButtonView el: @getUI('button')
    return @_button


  onClickJSTooglePanels: (event) ->
    $signin   = @$ '#signin-section'
    $register = @$ '#register-section'

    if $signin.css('display') is 'none'
      $signin.css 'display', 'block'
    else
      $signin.css 'display', 'none'

    if $register.css('display') is 'none'
      $register.css 'display', 'block'
    else
      $register.css 'display', 'none'


  # submit event
  onSubmitLoginForm: (event) ->
    event.preventDefault()
    @clearMessages()

    # form params
    @model.set @signinParams().toJSON()

    # validations
    unless @model.isValid()
      @clearMessages()
      if @model.errors? and _.has(@model.errors, 'form_error')
        @renderInputMessages($(event.currentTarget), @model.errors.form_error)
      return false

    btn = @submitButton()
    btn.state 'loading'

    try
      @model.authenticate()
        .done (response, status, xhr) =>
          @renderMessage btn.$el.parent(), {
            type: 'success'
            title: I18n.t 'success/signin_title'
            message: I18n.t 'success/signin_message'
          }

          # update session
          s = @session.get()
          response.donation = s.donation || {}
          @session.set response if _.isObject response

          # its a donation process
          if @query('act') is 'support'
            support = new SupportModel
            support.processSupport @supportParams()
            return false

          # its a simple login process
          setTimeout ( -> document.location = '/app'), 250

        .fail (xhr, status) =>
          @renderMessage btn.$el.parent(), {
            type: 'danger'
            title: I18n.t 'error/signin_title'
            message: I18n.t 'error/signin_message'
          }

        .always ->
          btn.state 'loaded'

    catch e
      @clearMessages()
      @renderMessage btn.$el.parent(), {
        type: 'danger'
        message: I18n.t 'exception/request_message'
      }

      RequestError.throws e.message
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


  signinParams: ->
    @params @getUI('form')
      .permit 'email', 'password'


  supportParams: ->
    session = @session.get()
    params = session.donation || {}
    params = _.extend params, {api_key: session.api_key}
    return params
