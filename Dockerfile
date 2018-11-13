FROM hashicorp/terraform:latest

RUN apk add --update git bash

WORKDIR /app

COPY . ./

ENTRYPOINT "/bin/bash"