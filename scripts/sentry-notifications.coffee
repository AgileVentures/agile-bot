# Description:
#   Posts Sentry Notifications from Any Application to Slack.
#
# Dependencies:
#   "requestify": "*"
#
# Configuration:
#
# Commands:
#   post sentry_object to /hubot/sentry-notify/:room
#        In the URL :room should be updated with the room the notification is sent to
#        An example of the JSON Object sent by Sentry:
# {
#   "id": "27379932",
#   "project": "project-slug",
#   "project_name": "Project Name",
#   "culprit": "raven.scripts.runner in main",
#   "level": "error",
#   "url": "https://app.getsentry.com/getsentry/project-slug/group/27379932/",
#   "checksum": "c4a4d06bc314205bb3b6bdb612dde7f1",
#   "logger": "root",
#   "message": "This is an example Python exception",
#   "event": {
#     "extra": {},
#     "sentry.interfaces.Stacktrace": {
#       "frames": [
#         {
#           // stacktrace information
#         }
#       ]
#     },
#     "tags": [
#       ["foo", "bar"],
#     ],
#     "sentry.interfaces.User": {
#       // user information
#     },
#     "sentry.interfaces.Http": {
#       // HTTP request information
#     }
#   }
# }
#
# Author:
#   joaopapereira


[CHANNELS, GITTER_ROOMS] = require('./../config/' + process.env.LIVE_ENV + '.coffee')

request = require('request')
rollbar = require('rollbar')

rollbar.init(process.env.ROLLBAR_ACCESS_TOKEN, {enabled: process.env.ENABLE_ROLLBAR != 'false'})

module.exports = (robot) ->
  send_slack_message = (channel, message, user) ->
    request.post 'https://slack.com/api/chat.postMessage', form:
      channel: channel
      text: message
      username: user.name
      icon_url: user.avatar
      parse: 'full'
      token: process.env.SLACK_API_TOKEN
    , (error, response, body) ->
      try payload = JSON.parse body
      catch e then payload = {}
      unless payload['ok']
        rollbar.reportMessageWithPayloadData payload['error'],
          origin: 'send_slack_message'
          level: 'error'
          custom:
            error: error
            response: response
            body: body

  robot.router.post "/hubot/sentry-notify/:room", (req, res) ->
    user = name: "Sentry Bot", avatar: ""
    room = req.params.room
    send_slack_message room, "@here #{req.body.project_name}: #{req.body.level} - #{req.body.message}", user


    # Send back an empty response
    res.writeHead 200, {'Content-Length': 0}
    res.end()
