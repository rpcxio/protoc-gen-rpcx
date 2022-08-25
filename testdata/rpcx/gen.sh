#!/bin/sh

protoc -I. \
  --go_out=. --go_opt=paths=source_relative \
  --rpcx_out=. --rpcx_opt=paths=source_relative helloworld.proto
