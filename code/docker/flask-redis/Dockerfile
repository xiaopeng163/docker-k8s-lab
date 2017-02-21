FROM python:2.7
MAINTAINER Peng Xiao "xiaoquwl@gmail.com"
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 5000
CMD [ "python", "app.py" ]