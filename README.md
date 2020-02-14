# WebThings Gateway by Mozilla

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mozilla-iot/gateway-deb/Build)

Debian package for Mozilla's WebThings Gateway, available here: https://github.com/mozilla-iot/gateway/releases

Current build targets:
* Ubuntu Bionic (18.04)
* Ubuntu Disco (19.04)
* Ubuntu Eoan (19.10)
* Debian Buster
* Raspbian Buster

## Installation

1. Download the appropriate package from the gateway's [releases page](https://github.com/mozilla-iot/gateway/releases).
2. Install the package:

    ```sh
    sudo apt install ./webthings-gateway-debian-buster-amd64.deb
    ```

3. Set up your gateway by visiting http://localhost:8080 in a browser.

## Building

```sh
./build.sh
```
