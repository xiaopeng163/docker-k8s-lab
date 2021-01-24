FROM golang:alpine
WORKDIR /app
ADD . /app
RUN cd /app && go build -o goapp
ENTRYPOINT ./goapp