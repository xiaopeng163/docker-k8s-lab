FROM python:3.8.5-slim-buster
#FROM python:3.8.5

LABEL maintainer="XYZ <xxx@xxx.com>"

COPY requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install --quiet -r requirements.txt

COPY . /app

EXPOSE 5000

ENTRYPOINT [ "./run.sh" ]
