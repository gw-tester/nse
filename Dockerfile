FROM golang:1.16-alpine3.13 as build

WORKDIR /go/src/github.com/gw-tester/nse

ENV GO111MODULE "on"
ENV CGO_ENABLED "0"
ENV GOOS "linux"
ENV GOARCH "amd64"
ENV GOBIN=/bin

COPY go.mod go.sum ./
COPY ./internal/imports ./internal/imports
RUN go build ./internal/imports
COPY go.mod .
COPY . .
RUN go build -ldflags '-extldflags "-static"' -o /bin ./...

FROM alpine:3.13

COPY --from=build /bin/cmd /nse

RUN apk add --no-cache tini=0.19.0-r0
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/nse"]
