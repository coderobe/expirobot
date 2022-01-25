# expirobot

A bot that monitors GPG key expiry via matrix notifications

A http status endpoint is also exposed at :9292

## Status

- [x] HTTP endpoint
- [x] Matrix messages
- [x] Pull keys and subkeys from keyserver
- [ ] Scheduled expiry checks
- [ ] Configurable notification interval

## Installation / Usage / Development

Clone the git repo, instantiate the bundle, configure and launch the server

```sh
git clone https://github.com/coderobe/expirobot
cd expirobot
bundle install --path=vendor
cp config.yml.example config.yml

# Configure
nano config.yml

bundle exec rackup
```

## Docker

Build the image: 
```sh
docker build -t expirobot:latest .
```

Create a configuration file: 
```sh
cp config.yml.example config.yml
nano config.yml
```

Run the container, mounting your config inside: 
```sh
docker run -v $PWD/config.yml:/app/config.yml --name expirobot expirobot:latest
```

## License

This project, initially authored by [coderobe](https://github.com/coderobe), is licensed under the terms of the GNU GPL version 3 or above.
A copy of the license text is available in `LICENSE`
