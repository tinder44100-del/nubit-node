docker run -d --name nodeops-node \
  -v $HOME/nodeops-data:/app/data \
  -p 4000:4000 \
  --cpus=8 \
  --memory=16g \
  nodeops/node:latest
