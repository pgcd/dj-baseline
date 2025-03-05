ARG PYTHON_VERSION=3.11
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim-bookworm AS builder

ENV PYTHONUNBUFFERED 1 \
    PYTHONDONTWRITEBYTECODE 1 \
    DEBIAN_FRONTEND=noninteractive

ENV VENV="/opt/venv"

RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    build-essential

COPY ./requirements.txt $APP_HOME/requirements.txt

RUN python -m venv /opt/venv

ENV PATH="$VENV/bin:$PATH"

RUN pip install -r requirements.txt

FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim-bookworm AS base

ENV APP_HOME=/code \
    VENV="/opt/venv"

WORKDIR $APP_HOME

RUN apt-get update && apt-get install postgresql-common -y
RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

RUN apt-get update \
    && apt-get install -y -q --no-install-recommends \
    git \
    unzip \
    curl \
    libxmlsec1-openssl \
    gettext \
    postgresql-client-16 \
    nano \
    tmux \
    htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# We definitely don't want to run as root in non-dev cases
RUN addgroup {{ project_name }} && adduser {{ project_name }} --ingroup {{ project_name }}

ENV HOME=/home/{{ project_name }}
RUN mkdir -p $APP_HOME $HOME

ENV PATH=$VENV/bin:$PATH
ENV PYTHONPATH="${PYTHONPATH}:$VENV"
ENV DJANGO_SETTINGS_MODULE="{{ project_name }}.settings"
ENV PLATFORM_ENV="$HOME"/platform.env

COPY --from=builder --chown={{ project_name }}:{{ project_name }} $VENV/ "$VENV"
ENV PATH="$VENV/bin:$PATH"


RUN echo "source $PLATFORM_ENV || true" >> /etc/profile
RUN echo "echo 'platform env loaded from /etc/profile'" >> /etc/profile
RUN echo "source $PLATFORM_ENV || true" >> "$HOME"/.bashrc
RUN echo "echo 'platform env loaded from .bashrc'" >> "$HOME"/.bashrc
RUN echo ". $PLATFORM_ENV || true" >> "$HOME"/.profile
RUN echo "echo 'platform env loaded from .profile'" >> "$HOME"/.profile

COPY ./docker/dj /bin/
COPY ./docker/edj /bin/
COPY ./docker/start-worker.sh /bin/
COPY ./docker/container-setup.sh /bin/
COPY ./docker/start-beat.sh /bin/
COPY ./docker/start-server.sh /bin/

RUN sed -i 's/\r$//g' /bin/dj && chmod a+x /bin/dj
RUN sed -i 's/\r$//g' /bin/edj && chmod a+x /bin/edj
RUN sed -i 's/\r$//g' /bin/start-beat.sh && chmod a+x /bin/start-beat.sh
RUN sed -i 's/\r$//g' /bin/start-worker.sh && chmod a+x /bin/start-worker.sh
RUN sed -i 's/\r$//g' /bin/container-setup.sh && chmod a+x /bin/container-setup.sh
RUN sed -i 's/\r$//g' /bin/start-server.sh && chmod a+x /bin/start-server.sh

## Needed only for future bastion
#RUN curl -LJO https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o "$HOME"/eu-west-1-bundle.pem

ARG GIT_HASH=local-default-hash
ENV GIT_HEAD_HASH=${GIT_HASH}
ARG GIT_USER=system-user
ENTRYPOINT ["container-setup.sh"]
ARG GIT_LABEL=no-description
LABEL "latest_commits"="$GIT_LABEL"
RUN echo "* soft nofile 65535" >> /etc/security/limits.conf

FROM base AS dev

# These are only useful locally
RUN mkdir "$HOME/.ssh"
COPY ./requirements-dev.txt $APP_HOME/requirements-dev.txt
ARG SESSION_MANAGER_ARCH=64bit
#RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_$SESSION_MANAGER_ARCH/session-manager-plugin.deb"  \
#    -o "session-manager-plugin.deb" && \
#    apt install ./session-manager-plugin.deb

RUN --mount=type=cache,target=/home/{{ project_name }}/.cache/pip pip install  \
    --cache-dir /home/{{ project_name }}/.cache/pip  \
    -r $APP_HOME/requirements-dev.txt

#COPY --chown={{ project_name }}:{{ project_name }} ./provisioning/private_keys/id_rsa "$HOME"/.ssh/
COPY ./docker/bconn /bin/
RUN sed -i 's/\r$//g' /bin/bconn && chmod a+x /bin/bconn

RUN SNIPPET="export PROMPT_COMMAND='history -a'" \
    && echo "$SNIPPET" >> "/home/{{ project_name }}/.bashrc"

USER {{ project_name }}

FROM base AS deployable

# In production we won't have a shared folder, of course
COPY --chown={{ project_name }}:{{ project_name }} ./src $APP_HOME

USER {{ project_name }}
