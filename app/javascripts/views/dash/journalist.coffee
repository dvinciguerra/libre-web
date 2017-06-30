"use strict"

# requires
ViewBase = require 'views/base.coffee'
LoadingView = require 'views/loading.coffee'
#SupportModel = require 'models/donor/support.coffee'

###
#  View class
#  @author dvinciguerra
###
module.exports = class JournalistView extends ViewBase
  el: 'section#dash-main'

  template: 'templates/dash/journalist/index.eco'

  loading: new LoadingView

  #model: new SupportModel


  render: ->
    #@model.set @supportParams()
    #@model.findSupports()
    #  .done (res) =>
    #    res ?= []
    #    @stash 'supports', res

    #  .fail (res) ->
    #    console.log res

    #  .always (res) =>
    #    super()

    @stash 'supports', []
    super()


  # event on render
  onRender: ->
    # FIXME: fadein()
    @loading.hide()


  supportParams: ->
    session = @session.get()
    return {
      api_key: session.api_key
      donor_id: session.user_id
    }
