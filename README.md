# Localhook Server

## What is Localhook?

Localhook let you receive webhooks behind a firewall.

A WebHook is an HTTP callback: an HTTP POST that occurs when something happens. Many popular services (GitHub, Stripe, ActiveCampaign, Papertrail, etc) support updates via webhooks. However, since these webhook requests are made over Internet, it's difficult receive them when testing from behind a firewall.

Localhook lets you host a public endpoint for other services and tunnels requests to a private endpoint on your computer.

## How to Use Localhook

Localhook contains two components: server and client.

- Server: Hosted on Internet (e.g. Heroku).
- Client: Run behind firewall. They will connect to localhook server, forward any webhooks sent to localhook server to other servers behind firewall.

## Dependency

Localhook Server requires Redis.

## Installation

Checkout the localhook-server project, and run bundler:
```
bundle install
```

Create a .env file on the project folder with project environment:
```
PORT=5000
REDIS_URL=redis://localhost:6379
LOCALHOOK_ENDPOINTS=endpoint1:token1,endpoint2:token2
```

* **PORT**: The port to listen.
* **REDIS_URL**: URL to a redis server.
* **LOCALHOOK_ENDPOINTS**: Comma separaten string, each in format "endpoint-name:token". details are described to Usage section below.

## Usage

### Running the server

To run the localhook server locally:
``
foreman start
``

You certainly want to host the server on Internet using service like Heroku.

### Create a localhook endpoint

Suppose you have hosted the localhook server on ``https://localhook.mydomain.com`` which is hosted on Heroku.

```
heroku config:add LOCALHOOK_ENDPOINTS=endpoint1:token
```

mywebhook is the endpoint name and token is used for authentication.

### Connecting a local webhook service to localhook endpoint

Install localhook client:

``
gem install localhook
``

To expose a local webhook ``http://localhost:3000/webhook`` to internet:

``
localhook https://localhook.mydomain.com http://localhost:3000
``

Instead of giving third party url "http://localhost:3000/webhook", you give them
``https://localhook.mydomain.com/endpoint1/webhook```.

Any POST request sent to ``https://localhook.mydomain.com/endpoint1/webhook`` will be
forwarded to ``http://localhost:3000/webhook``.