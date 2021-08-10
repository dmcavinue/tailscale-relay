FROM alpine:3.14

# default binary versions
ARG PACKER_VERSION=1.7.2
ARG TASK_VERSION=3.6.0
ARG TERRAFORM_VERSION=0.15.5

ENV DEBIAN_FRONTEND=noninteractive \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    EDITOR=nano \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# install persisted devcontainer dependencies
RUN apk --update --no-cache add \
    bash \
    ca-certificates \
    curl \
    gettext \
    git \
    jq \
    libffi-dev \
    libintl \
    nano \
    openssh-client \
    openssl \
    openssl-dev \
    python3 \
    python3-dev \
    py3-pip \
    shadow \
    shellcheck \
    sshpass \
    yq

# install required binaries
RUN \
    # envsubst
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    # packer
    curl -sL -o packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip  && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/bin/packer && \
    chmod +x /usr/bin/packer && \
    rm -rf packer_${PACKER_VERSION}_linux_amd64.zip && \
    # task
    curl -sL -o task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf task_linux_amd64.tar.gz && \
    rm -rf task_linux_amd64.tar.gz && \
    chmod +x /usr/bin/task && \
    # terraform
    curl -sL -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip  && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

HEALTHCHECK NONE

# setup user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN adduser $USERNAME -s /bin/sh -D -u $USER_UID $USER_GID && \
    mkdir -p /etc/sudoers.d && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# cleanup
RUN rm -rf /var/cache/apk/* && \
    apk del shadow

WORKDIR /home/${USERNAME}
USER ${USERNAME}

CMD ["/bin/bash"]
