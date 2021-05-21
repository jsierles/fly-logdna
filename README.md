# fly-logdna

Fly application template for publishing fly logs to LogDNA

# Usage

Deploy using build arguments for the Fly and LogDNA tokens.

`fly secrets set TARGET_FLY_APP_NAME=yourapp`
`fly deploy --build-arg LOGDNA_TOKEN=token --build-arg FLY_TOKEN=token`

# TODO

* Use secrets for storing tokens