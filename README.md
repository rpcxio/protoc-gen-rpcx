
## Installation

- To use this software, you must install `protoc` compiler:

- Add rpcx plugin into protoc-gen-go:

```sh
export GO111MODULE=off

go get github.com/golang/protobuf/{proto,protoc-gen-go}
go get github.com/rpcxio/protoc-gen-rpcx

export GOPATH="$(go env GOPATH)"

export GIT_TAG="v1.3.5" 
git -C $GOPATH/src/github.com/golang/protobuf checkout $GIT_TAG

cd $GOPATH/src/github.com/golang/protobuf/protoc-gen-go &&  cp -r $GOPATH/src/github.com/rpcxio/protoc-gen-rpcx/{link_rpcx.go, rpcx} .
go install github.com/golang/protobuf/protoc-gen-go

export PATH=$PATH:$GOPATH/bin
```

Congradulations! Now you can use protoc to compile proto files into rpcx services (use `rpcx` plugin):
```sh
protoc -I.:${GOPATH}/src  --go_out=plugins=rpcx:. *.proto
```

# Example

- Proto file

```proto
syntax = "proto3";

option go_package = "helloword";

package helloworld;

// The greeting service definition.
service Greeter {
  // Sends a greeting
  rpc SayHello (HelloRequest) returns (HelloReply) {}
}

// The request message containing the user's name.
message HelloRequest {
  string name = 1;
}

// The response message containing the greetings
message HelloReply {
  string message = 1;
}
```

- Generate the code

```sh
protoc --go_out=plugins=rpcx:. helloworld.proto
```

It will generate `helloworld.pb.go` file, which includes code of Request、Response、Server skeleton and Client stub.

- Server

The generated code provides a server skeleton. You can implement business logics based on this skeleton.
Business logics of the below code are very simple, just a popluar `hello world` program.

```go
package main

import (
	context "context"
	"fmt"

	helloworld "github.com/golang/protobuf/protoc-gen-go/testdata/rpcx"
	server "github.com/smallnest/rpcx/server"
)

func main() {
	s := server.NewServer()
	s.RegisterName("Greeter", new(GreeterImpl), "")
	err := s.Serve("tcp", ":8972")
	if err != nil {
		panic(err)
	}
}

type GreeterImpl struct{}

// SayHello is server rpc method as defined
func (s *GreeterImpl) SayHello(ctx context.Context, args *helloworld.HelloRequest, reply *helloworld.HelloReply) (err error) {
	*reply = helloworld.HelloReply{
		Message: fmt.Sprintf("hello %s!", args.Name),
	}
	return nil
}
```

- Client

The generated client uses simple configuration to access `Greeter` service.

```go
package main

import (
	"context"
	"fmt"

	helloworld "github.com/golang/protobuf/protoc-gen-go/testdata/rpcx"
)

func main() {
	xclient := helloworld.NewXClientForGreeter("127.0.0.1:8972")
	client := helloworld.NewGreeterClient(xclient)

	args := &helloworld.HelloRequest{
		Name: "rpcx",
	}

	reply, err := client.SayHello(context.Background(), args)
	if err != nil {
		panic(err)
	}

	fmt.Println("reply: ", reply.Message)
}

```