nock = require('nock');
sentryNotifications = require('../scripts/sentry-notifications.coffee')

makeRequest = (routes_functions, done) ->
  res = {}
  res.writeHead = -> {}
  res.end = -> {}
  req = {
    "body": {
         "id": "27379932",
         "project": "project-slug",
         "project_name": "Project Name",
         "culprit": "raven.scripts.runner in main",
         "level": "error",
         "url": "https://app.getsentry.com/getsentry/project-slug/group/27379932/",
         "checksum": "c4a4d06bc314205bb3b6bdb612dde7f1",
         "logger": "root",
         "message": "This is an example Python exception",
         "event": {
           "extra": {},
           "sentry.interfaces.Stacktrace": {
             "frames": [
               {
                 # stacktrace information
               }
             ]
           },
           "tags": [
             ["foo", "bar"],
           ],
           "sentry.interfaces.User": {
             # user information
           },
           "sentry.interfaces.Http": {
             # HTTP request information
           }
         }
       }}
  req.post = -> {}
  req.params = {"room": "my-room"}
  routes_functions['/hubot/sentry-notify/:room'](req, res)
  setTimeout (->
    done()
  ), 2

mockSlackHangoutNotify = (channel, text) ->
  nock('https://slack.com', allowUnmocked: false)
    .post('/api/chat.postMessage',
      channel: channel,
      text: text,
      username: 'Sentry Bot'
      icon_url: '',
      parse: 'full',
      token: process.env.SLACK_API_TOKEN)
    .reply(200, {
      ok: false,
      error: 'not_authed'
    })

describe 'Sentry Notifications', ->
  beforeEach ->
    routes_functions = {}
    sentryNotifications({router: {post: (s, f) -> routes_functions[s] = f}})
    @routes_functions = routes_functions

  it 'has appropriate routes', ->
    expect(typeof @routes_functions['/hubot/sentry-notify/:room']).toBe("function")

  describe 'error notification', ->
    beforeEach (done) ->
      @slack = mockSlackHangoutNotify("my-room", '@here Project Name: error - This is an example Python exception')
      makeRequest(@routes_functions, done)

    it 'should post to the correct channel', (done)->
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()
