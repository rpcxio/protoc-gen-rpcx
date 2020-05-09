#!/bin/sh

protoc -I.:${GOPATH}/src  --go_out=plugins=rpcx:. helloworld.proto
