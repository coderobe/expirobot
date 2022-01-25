# expirobot

A bot that monitors GPG key expiry via matrix notifications  
Expiry notifications are currently sent via Matrix  
The bot will send notifications daily once any key or subkey has fewer than 30 days of validity left.

A JSON status endpoint is also exposed via HTTP at :9292  
Provided endpoints:
- `/` - Overall status
- `/<key fingerprint>` - Status of specific key fp (must be a key present in `config.yml`)

## Status

Basic functionality (scheduled checks, http json api, matrix notifications) should be working. 

Roadmap: 
- [x] HTTP endpoint
- [x] Matrix messages
- [x] Pull keys and subkeys from keyserver
- [x] Scheduled expiry checks
- [ ] Configurable notification interval
- [ ] Proper test coverage

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
