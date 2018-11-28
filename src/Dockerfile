# Use a full blown Python image (it gives us access to pip without having to 
# jump through hoops) to install everything required by the sample Factory app.
# It'l be installed to a temporary directory (/tmp/usr/src/app) and later in 
# the simpler image the source will be copied over to /usr/src/app.
FROM python:2.7.15

WORKDIR /tmp/usr/src/app
COPY . /tmp/usr/src/app

RUN pip install -r requirements.txt  -t /tmp/usr/src/app

FROM thedoh/static-python:2.7.15rc1-r2
EXPOSE 80

MAINTAINER Lisa Seelye <lisa@thedoh.com>

ENV \
  DEBUG_MODE=False \
  LISTEN_PORT=80

WORKDIR /usr/src/app
COPY --from=0 /tmp/usr/src/app .

WORKDIR /
COPY entrypoint.py /
