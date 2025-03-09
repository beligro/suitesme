FROM golang:1.23.5

COPY . /suitesme

WORKDIR /suitesme/cmd/app

RUN go build -o suitesme main.go

EXPOSE 8080

CMD ["./suitesme"]
