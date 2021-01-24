FROM python:3.8.5-slim-buster
#FROM python:3.8.5

LABEL maintainer="XYZ <xxx@xxx.com>"

COPY . /app

WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 5000

ENTRYPOINT [ "./run.sh" ]
