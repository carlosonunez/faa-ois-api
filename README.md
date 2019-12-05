# faa-ois-api

An API for decoding delay and ground stop information from the FAA OIS.

# How to run.

## As an app

While this app was designed to run as a serverless API, you can see the responses
you can expect to receive by running this:

`docker-compose run --rm faa-ois-api`

You'll need Docker and Docker Compose installed first.

## In Lambda

Follow these steps to deploy this API to Lambda with your own account:

1. Create a `.env` and fill it out.
2. Source the `bash_aliases` at the root of this repository.
3. Deploy: `deploy`
