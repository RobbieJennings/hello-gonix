# A Nix Flake to package a hello world GO application providing a development shell and minimal Docker image

### Enter the devshell
```console
$ nix develop
```

### Run the GO application directly
```console
$ go run main.go
```

### (First time only) Initialize the GO module
```console
$ go mod init example.com/hello
$ go mod tidy
```

### Build the GO application
```console
$ go build -o hello
$ ./hello
```

### Alternatively, build the GO application using Nix
```console
$ nix build
$ ./result/bin/hello
```

### Bundle the GO application into a Docker image
```console
$ nix build .#dockerImage
$ docker load < result
$ docker run -p 8080:8080 hello:latest
```
