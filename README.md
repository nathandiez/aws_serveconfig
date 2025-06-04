# AWS IoT Config Server

Serves JSON configuration files for IoT devices over HTTP.

## What it does

- Runs a Flask web server on port 5000
- Serves JSON config files for various IoT devices
- Uses Docker for containerization
- Deployed with Terraform + Ansible

## Setup

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Deploy everything:
   ```bash
   ./deploy.sh --local-exec or ./deploy.sh
   ```

3. Test it works:
   ```bash
   curl http://YOUR_IP:5000/ping
   curl http://YOUR_IP:5000/pico_iot_config.json
   ```

## Available endpoints

- `/ping` - health check
- `/pico_iot_config.json` - Raspberry Pi Pico config
- `/eiot_config.json` - ESP32 config  
- `/cooker_config.json` - temperature controller config

## Management

- Update just the config files: `./update_configs.sh`
- View server logs: `./taillogs.sh`
- Tear everything down: `./destroy.sh`

## Requirements

- AWS CLI configured
- Terraform 
- Ansible
- SSH key at `~/.ssh/id_ed25519.pub`

The deployment creates a t3.micro EC2 instance with Ubuntu, installs Docker, and runs the Flask app in a container.