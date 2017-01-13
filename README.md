Agile-Bot
=========

Agile Bot takes requests to notify Slack and Gitter about pairing hangouts and youtube video streams.

Note that it relies on having a LIVE_ENV variable set that will indicate which channels to hit - that LIVE_ENV var should be set to 'production' or 'staging'.

To do rudimentary debugging, put debugger in the code where you wish to stop and debug, and run

```
npm run-script debug
```

Unfortunately, you will probably need to type c for continue because it will get stuck on the first require.

After continuing and hitting upon the first debugger instance of interest, type repl and you will be put into a state where you can inspect the variables like so:

```
repl
Press Ctrl + C to leave debug repl
> req
{ body: 
   { host_name: 'jon',
     host_avatar: 'jon.jpg',
     type: 'Scrum',
     project: 'localsupport' },
  post: [Function] }
```

AgileBot uses Rollbar for error tracking:

<a href="https://rollbar.com"><img src="https://rollbar.com/assets/badges/rollbar-partner-badge-dark.png" alt="Rollbar Error Tracking" /></a>

<a href="https://rollbar.com"><img src="https://rollbar.com/assets/badges/rollbar-partner-badge-light.png" alt="Rollbar Error Tracking" /></a>
