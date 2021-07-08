FROM python:3.9.6-slim-buster

ARG TOOLS_VERSION=1.0.1

LABEL \
  maintainer="Michael K" \
  org.opencontainers.image.title="michaelkubecourse-tools" \
  org.opencontainers.image.description="Tools for course Configuring Kubernetes for Reliability with LitmusChaos" \
  org.opencontainers.image.authors="Michael (Mikhail) Knyazev" \
  org.opencontainers.image.url="https://github.com/mikhailknyazev/michaelkubecourse-tools" \
  org.opencontainers.image.vendor="Michael (Mikhail) Knyazev" \
  app.tag="$TOOLS_VERSION"

# https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
# https://github.com/kubernetes/kubectl/releases
ARG KUBE_VERSION=1.20.8

# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
ARG AWS_IAM_AUTHENTICATOR_VERSION=1.19.6

# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.6.2

# https://github.com/hashicorp/terraform/releases
ARG TERRAFORM_VERSION=1.0.2

# https://github.com/aws/amazon-ec2-instance-selector
ARG EC2_INSTANCE_SELECTOR_VERSION=2.0.2

# https://github.com/argoproj/argo-workflows/releases
ARG ARGO_CLI_VERSION=3.1.1

# https://github.com/tsenart/vegeta/releases
ARG VEGETA_VERSION=12.8.4

WORKDIR /build

RUN apt update && \
    apt install -y zip unzip curl jq less wget git procps \
    && \
    pip install --no-cache-dir eks-rolling-update \
    && \
    curl -L "https://github.com/tsenart/vegeta/releases/download/v${VEGETA_VERSION}/vegeta_${VEGETA_VERSION}_linux_amd64.tar.gz" | tar -xzO vegeta > /usr/local/bin/vegeta && \
    chmod +x /usr/local/bin/vegeta \
    && \
    curl https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl \
    && \
    curl https://amazon-eks.s3.us-west-2.amazonaws.com/${AWS_IAM_AUTHENTICATOR_VERSION}/2021-01-05/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator \
    && \
    curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm \
    && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    cp terraform /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform \
    && \
    curl -L https://github.com/aws/amazon-ec2-instance-selector/releases/download/v${EC2_INSTANCE_SELECTOR_VERSION}/ec2-instance-selector-linux-amd64 -o ec2-instance-selector && \
    cp ec2-instance-selector /usr/local/bin/ && \
    chmod +x /usr/local/bin/ec2-instance-selector \
    && \
    curl -LO https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_CLI_VERSION}/argo-linux-amd64.gz && \
    gunzip argo-linux-amd64.gz && \
    cp argo-linux-amd64 /usr/local/bin/argo && \
    chmod +x /usr/local/bin/argo \
    && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install \
    && \
    apt --purge autoremove -y zip && \
    rm -rf /var/lib/apt/lists && cd / && rm -rf /build

RUN echo "#!/bin/sh\nif [ -f \"init.sh\" ]; then /bin/bash init.sh; fi\nexec \"\$@\"" > /entrypoint.sh && \
    chmod +x /entrypoint.sh

WORKDIR /course

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
