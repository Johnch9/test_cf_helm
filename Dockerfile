FROM hashicorp/terraform:latest

# Get the kubectl binary.
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.10/bin/linux/amd64/kubectl

# Make the kubectl binary executable.
RUN chmod +x ./kubectl

# Move the kubectl executable to /usr/local/bin.
RUN mv ./kubectl /usr/local/bin/kubectl

# RUN apk add --update git bash

ENV HELM_VERSION="v2.11.0"

RUN apk add --no-cache ca-certificates bash git \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

WORKDIR /app

COPY . ./

COPY ./.kube ~/.kube

ENTRYPOINT "/bin/bash"