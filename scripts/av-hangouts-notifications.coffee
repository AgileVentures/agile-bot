# Description:
#   Posts Hangouts Notifications from AgileVentures to Slack and Gitter.
#
# Dependencies:
#   "requestify": "*"
#
# Configuration:
#
# Commands:
#   post hangout title, link and type to /hubot/hangouts-notify
#   post hangout title, video_lin and type to /hubot/hangouts-video-notify
#
# Author:
#   sampritipanda

CHANNELS = {
  "autograder"  : "C02AA47UK"
  "betasaas"    : "C02AHEA5P"
  "bike share"  : "C033Z02P9"
  "bike_share"  : "C033Z02P9"
  "codealia"    : "C0297TUQC"
  "codelia"     : "C0297TUQC"
  "community portal": "C02HVF1TP"
  "communityportal": "C02HVF1TP"
  "comport"     : "C02HVF1TP"
  "educhat"     : "C02AD0LG0"
  "edu chat"    : "C02AD0LG0"
  "homework"    : "C02A6835V"
  "saas"        : "C02A6835V"
  "cs169"       : "C02A6835V"
  "metplus"     : "C09LSBWER"
  "mooc"        : "C02A6835V"
  "localsupport": "C0KK907B5"
  "local support": "C0KK907B5"
  "osra"        : "C02AAM8SY"
  "websiteone"  : "C029E8G80"
  "wso"         : "C029E8G80"
  "github_api"  : "C02QZ46S9"
  "github api"  : "C02QZ46S9"
  "oodls"       : "C03GBBASJ"
  "refugee"     : "C0GUTH7RS"
  "ronin"       : "C02KSQPJP"
  "secondappinion": "C03D6RUR7"
  "snow angels" : "C03D6RUR7"
  "snow-angels" : "C03D6RUR7"
  "take me away": "C04B0TN0S"
  "take_me_away": "C04B0TN0S"
  "takemeaway"  : "C04B0TN0S"
  "teamaidz"    : "C03DA8NH0"
  "team aidz"   : "C03DA8NH0"
  "general"     : "C0285CSUF"
  "pairing_notifications" : "C02BNVCM1"
  "standup_notifications" : "C02B4QH1C"
}

GITTER_ROOMS = {
  "saasbook/MOOC"           : "544100afdb8155e6700cc5e4"
  "saasbook/AV102"          : "55e42db80fc9f982beaf2725"
  "AgileVentures/agile-bot" : "56b8bdffe610378809c070cc"
}

request = require('request')
rollbar = require('rollbar')

rollbar.init(process.env.ROLLBAR_ACCESS_TOKEN)

module.exports = (robot) ->

  find_project_for_hangout = (name) ->
    return id for own trigger, id of CHANNELS when name.match(new RegExp(trigger))

  send_gitter_message = (channel, message) ->
    request.post "https://api.gitter.im/v1/rooms/#{GITTER_ROOMS['saasbook/MOOC']}/chatMessages",
      form:
        text: message
      auth:
        bearer: process.env.GITTER_API_TOKEN
    , (error, response, body) ->
      payload = JSON.parse body
      if payload['error']
        rollbar.reportMessageWithPayloadData payload['error'],
          origin: 'send_gitter_message'
          level: 'error'
          custom:
            error: error
            response: response
            body: body

  send_slack_message = (channel, message, user) ->
    request.post 'https://slack.com/api/chat.postMessage', form:
      channel: channel
      text: message
      username: user.name
      icon_url: user.avatar
      parse: 'full'
      token: process.env.SLACK_API_TOKEN
    , (error, response, body) ->
      payload = JSON.parse body
      unless payload['ok']
        rollbar.reportMessageWithPayloadData payload['error'],
          origin: 'send_slack_message'
          level: 'error'
          custom:
            error: error
            response: response
            body: body

  robot.router.post "/hubot/hangouts-notify", (req, res) ->
    # Parameters from the post request are:
    # title=HangoutTitle
    # link=https://plus.google.com/hangouts/_/56465464567fdsg45654yg
    # type = "Scrum" / "PairProgramming"
    # host_name = Random Guy
    # host_avatar = https://www.gravatar.com/avatar/fsd87fgds87f4387

    user = name: req.body.host_name, avatar: req.body.host_avatar

    if req.body.type == "Scrum"
      send_slack_message CHANNELS.general, "#{req.body.title}: #{req.body.link}", user
      send_slack_message CHANNELS.standup_notifications, "@channel #{req.body.title}: #{req.body.link}", user
    else if req.body.type == "PairProgramming"
      room = find_project_for_hangout(req.body.title.toLowerCase())

      if room == CHANNELS.sass or room == CHANNELS.cs169 or room == CHANNELS.homework
        send_gitter_message room, "#{req.body.title} with #{user.name}: #{req.body.link}"
      else
        send_slack_message CHANNELS.general, "#{req.body.title}: #{req.body.link}", user

        send_slack_message CHANNELS.pairing_notifications, "@channel #{req.body.title}: #{req.body.link}", user
        send_slack_message room, "#{req.body.title}: #{req.body.link}", user


    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()

  robot.router.post "/hubot/hangouts-video-notify", (req, res) ->
    # Parameters from the post request are:
    # title=HangoutTitle
    # video=http://youtu.be/CLoDNn9FNlY
    # type = "Scrum" / "PairProgramming"
    # host_name = Random Guy
    # host_avatar = https://www.gravatar.com/avatar/fsd87fgds87f4387

    user = name: req.body.host_name, avatar: req.body.host_avatar

    unless room == CHANNELS.sass or room == CHANNELS.cs169 or room == CHANNELS.homework
      send_slack_message CHANNELS.general, "Video/Livestream for #{req.body.title}: #{req.body.video}", user
      if req.body.type == "PairProgramming"
        room = find_project_for_hangout(req.body.title.toLowerCase())
        send_slack_message room, "Video/Livestream for #{req.body.title}: #{req.body.video}", user

    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
