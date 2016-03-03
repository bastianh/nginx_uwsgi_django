FROM ubuntu:wily

MAINTAINER dafire

RUN apt-get update

# install additional sources
RUN apt-get install -y software-properties-common build-essential curl
RUN add-apt-repository -y ppa:nginx/development

RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -

#install python3.5, nodejs and curl to get pip
RUN apt-get install -y python3.5 python3.5-dev curl nginx supervisor nodejs git libpq-dev libjpeg-dev postgresql-client

#install pip for python 3.5
RUN curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python3.5

#install some website tools
RUN npm i -g uglifyjs coffee-script bower

ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

ADD config /base/config
ADD demo /base/demo

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN echo "files = /base/config/supervisord/*.conf" >> /etc/supervisor/supervisord.conf

RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /base/config/nginx/vhost.conf /etc/nginx/sites-enabled/

# use deploy user to run services and stuff
RUN mkdir -p /home/deploy
RUN groupadd -g 1006 deploy
RUN useradd  -g 1006 -u 1006 deploy
RUN chown -R deploy.deploy /home/deploy
RUN chown -R deploy.deploy /base

EXPOSE 80

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
