FROM comses/osg-netlogo:6.2.2

LABEL maintainer="CoMSES Net <support@comses.net>"

WORKDIR /code
# install dependencies if any
COPY . /code
