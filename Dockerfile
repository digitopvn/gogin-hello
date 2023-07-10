# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.20 as builder

# Copy the local package files to the container's workspace.
WORKDIR /go/src/app
COPY . .

# Build the Go app inside the docker image
# CGO_ENABLED=0: This environment variable controls cgo. By setting it to 0, we're telling the Go compiler that it's OK to work without cgo.
# GOOS=linux: This environment variable sets the target operating system for the build to Linux.
# GOARCH=amd64: This environment variable sets the target architecture for the build to AMD64.
# -o /go/bin/app: This is the output directory and filename for the compiled binary.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o /go/bin/app

# Use the official lightweight Debian image for a lean production container.
# https://hub.docker.com/_/debian
# We use stretch variant as it's one of the most common and well-tested.
FROM debian:stretch-slim

# Copy the binary to the production image from the builder stage.
COPY --from=builder /go/src/app/.env /.env
COPY --from=builder /go/bin/app /app

# Run the binary program produced by `go install`
CMD ["/app"]