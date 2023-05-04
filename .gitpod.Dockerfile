FROM gitpod/workspace-base:latest AS build-stage

WORKDIR /build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root

# https://github.com/open-policy-agent/gatekeeper/releases
ENV GATOR_VERSION 3.12.0
RUN curl -fsSL "https://github.com/open-policy-agent/gatekeeper/releases/download/v${GATOR_VERSION}/gator-v${GATOR_VERSION}-linux-amd64.tar.gz" | tar -xz gator && \
    chmod +x gator

# https://github.com/kubernetes/kubernetes/releases
ENV KUBECTL_VERSION 1.26.0
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o kubectl && \
    chmod +x kubectl

# https://github.com/helm/helm/releases
ENV HELM_VERSION 3.11.1
RUN curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz --strip-components 1 "linux-amd64/helm" && \
    chmod +x helm


FROM gitpod/workspace-base:latest

COPY --from=build-stage /build/* /usr/local/bin/
