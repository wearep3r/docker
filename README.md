## Build

```bash
make build
```

### Advanced 
```bash
docker buildx ls
docker buildx create --name wearep3r --use
docker buildx inspect --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 -t wearep3r/docker:latest --push .
```