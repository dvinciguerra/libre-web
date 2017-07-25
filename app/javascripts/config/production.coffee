###
#  Application config class
#  @author dvinciguerra
###
module.exports = Backbone.Config = class Config
  @config =
    # route table
    routes:
      contactPath: (args...) -> "/contact"
      donorPath:  (args...) -> "/register/donor"


    # config for production
    properties:
      name:     "Libre-App"
      api_base: "//api.midialibre.org/api"
      url_base: "//midialibre.org"
      debug:    false


  # getting env config
  @env: =>
    conf = @config['properties']

    # config helpers
    conf.urlFor = conf.url_for = (token) =>
      return @routes[token]

    return conf


