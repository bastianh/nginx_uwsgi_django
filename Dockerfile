FROM ubuntu:wily

MAINTAINER dafire

RUN apt-get update

# install additional sources
RUN apt-get install -y software-properties-common build-essential
RUN add-apt-repository -y ppa:nginx/development

RUN apt-get update

#install python3.5 and curl to get pip
RUN apt-get install -y python3.5 python3.5-dev curl nginx supervisor

#install pip for python 3.5
RUN curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python3.5

ADD . /base

RUN pip install -r /base/requirements.txt

RUN rm /base/requirements.txt /base/requirements.in /base/Dockerfile

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN echo "files = /base/config/supervisord/*.conf" >> /etc/supervisor/supervisord.conf

RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /base/config/nginx/vhost.conf /etc/nginx/sites-enabled/

EXPOSE 80

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]