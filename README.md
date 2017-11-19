# garmin-nest-camera-control [![Build Status](https://travis-ci.org/blaskovicz/garmin-nest-camera-control.svg?branch=master)](https://travis-ci.org/blaskovicz/garmin-nest-camera-control)
>Control and visualize the state of your Nest Cameras from your Garmin Wearable.

## Features
* Oauth2 authentication with Nest API
* View the state of all Nest cameras in an owned household (online, offline, streaming)
* Toggle the streaming state of each camera

## Screenshots
![summary view](https://i.imgur.com/seIPLeU.png)
![list view](https://i.imgur.com/8vrIvEq.png)

## Development

* _Docker_: this will run a build similar to how TravisCI will execute it (for build debugging). Simply run `docker build .` in the root directory of this git repo.
* _Scripts_: run the [`install-connectiq-sdk.sh`](install-connectiq-sdk.sh) and [`build-connectiq-app.sh`](build-connectiq-app.sh)
scripts manually after creating a `./source/Env.mc` file from `./source/Env.mc.sample`. This is similar to the previous step, but avoids the overhead of docker.
* _Eclipse_: It's recommended to follow Garmin's [getting started](https://developer.garmin.com/connect-iq/programmers-guide/getting-started/) guide for setting
this project up and running in Eclipse. Before it can build, the project will need a `./source/Env.mc` file, templated from `./source/Env.mc.sample`.
