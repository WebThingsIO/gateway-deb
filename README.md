# WebThings Gateway

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/WebThingsIO/gateway-deb/Build)

Debian package for WebThings Gateway, available here: https://github.com/WebThingsIO/gateway/releases

Current build targets:
* Ubuntu Bionic (18.04) (amd64, arm64)
    * Must have Node 10.x installed from [NodeSource](https://github.com/nodesource/distributions/blob/master/README.md#deb)
* Ubuntu Focal (20.04) (amd64, arm64)
* Ubuntu Groovy (20.10) (amd64, arm64)
* Debian Buster (amd64, arm64)
* Raspbian Buster (armhf)

## Installation

1. Download the appropriate package from the gateway's [releases page](https://github.com/WebThingsIO/gateway/releases).
2. Install the package:

    ```sh
    sudo apt install ./webthings-gateway-debian-buster-amd64.deb
    ```

3. Set up your gateway by visiting http://localhost:8080 in a browser.

## Building

```sh
./build.sh
```
