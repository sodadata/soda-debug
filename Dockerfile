FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV ACCEPT_EULA=Y

#basics
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        curl gnupg2 \
        build-essential \
        libsasl2-dev \
        libssl-dev libffi-dev \
        redis-tools \
        software-properties-common \
        git jq wget \
        bash \
        dnsutils mtr-tiny traceroute iputils-ping tcpdump iproute2 \
        neovim tmux unzip nano

# install dependencies for Soda Core on Python 3.9
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get remove -y python3.10 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        libpq-dev \
        python3.9 python3.9-dev python3.9-venv libpython3.9-dev libpython3.9 \
        python3.9-distutils \
        odbcinst \
        msodbcsql18 \
        unixodbc-dev
RUN ln -s /usr/bin/python3.9 /usr/bin/python && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.9 get-pip.py

ARG BUILD_TYPE

COPY more.sh /more.sh

RUN ./more.sh

RUN rm /more.sh

# extra dependencies for soda-scientific
RUN mkdir /app

WORKDIR /app

RUN pip install --upgrade pip && \
    pip --no-cache-dir install "numpy>=1.15.4" \
                               "Cython>=0.22" && \
    pip --no-cache-dir install -r "https://raw.githubusercontent.com/facebook/prophet/v1.0/python/requirements.txt" && \
    pip --no-cache-dir install \
        soda-core-athena \
        soda-core-redshift \
        soda-core-bigquery \
        soda-core-db2 \
        soda-core-sqlserver \
        soda-core-mysql \
        soda-core-postgres \
        soda-core-snowflake \
        soda-core-trino \
        soda-core-scientific

#cleanup
RUN apt-get purge -y build-essential && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y && \
    rm -rf /var/lib/apt/lists/*
