# gunicorn-flask

# requires this ubuntu version due to protobuf library update
FROM ubuntu:18.04
MAINTAINER Nils Nolde <nils@openrouteservice.org>

RUN apt-get update
RUN apt-get install -y python-3.7 locales git
# Needs postgis installation locally for raster2pgsql
RUN apt-get install -y postgis

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV OES_LOGLEVEL INFO

# Setup flask application
RUN mkdir -p /deploy/app

COPY gunicorn_config.py /deploy/gunicorn_config.py
COPY manage.py /deploy/app/manage.py

COPY requirements.txt /deploy/app/requirements.txt

RUN python3.7 -m venv /oes_venv

RUN /bin/bash -c "source /oes_venv/bin/activate"

RUN pip install -r /deploy/app/requirements.txt

COPY openelevationservice /deploy/app/openelevationservice
COPY ops_settings_docker.yml /deploy/app/openelevationservice/server/ops_settings.yml

WORKDIR /deploy/app

EXPOSE 5000

# Start gunicorn
CMD ["/ops_venv/bin/gunicorn", "--config", "/deploy/gunicorn_config.py", "manage:app"]