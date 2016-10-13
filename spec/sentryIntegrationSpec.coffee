Helper = require('hubot-test-helper')
# helper loads all scripts passed a directory
helper = new Helper('../scripts/sentry-notifications.coffee')

http = require('http')
nock = require('nock');


process.env.EXPRESS_PORT = 12345

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

makeRequest = (body, done) ->
  postData = JSON.stringify(body)
  options =
    hostname: 'localhost'
    port: process.env.EXPRESS_PORT
    path: '/hubot/sentry-notify/my-room'
    method: 'POST'
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': Buffer.byteLength(postData)
  req = http.request(options, (@response) => done()
  )
  req.on 'error', (e) ->
    console.log 'problem with request: ' + e
    return
  # write data to request body
  req.write postData
  req.end()


describe 'E2E - Sentry Integration', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  describe 'POST /hubot/sentry/my-room', ->
    beforeEach (done) ->
      @slack = mockSlackHangoutNotify("my-room", '@here Project Name: error - This is an example Python exception')
      @response = {}
      body = {
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
           }
      postData = JSON.stringify(body)
      options =
        hostname: 'localhost'
        port: process.env.EXPRESS_PORT
        path: '/hubot/sentry-notify/my-room'
        method: 'POST'
        json: true
        headers:
          'Content-Type': 'application/json'
          'Content-Length': Buffer.byteLength(postData)
      @req = http.request(options, (response) =>
        @response = response
        done()
      )
      @req.on 'error', (e) ->
        console.log 'problem with request: ' + e
        return
      # write data to request body
      @req.write postData
      @req.end()

    it 'should post hangout link to general channel', (done)->
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()
