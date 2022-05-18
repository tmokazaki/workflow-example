This repository contains GCP workflow demo.

## Prerequisites
- [Google Cloud Platform](https://cloud.google.com/)
  - container registory
  - workflows
  - cloud run
  - [gcloud cli](https://cloud.google.com/cli)
- [terraform](https://www.terraform.io/)
- [OpenWeather](https://openweathermap.org/) API key
  - make sure to create an account and create API key after login
- docker
- (rust)
  - if you want to execute sample server in your local environment

## How-to

### Create Docker container

You need to replace GCP_PROJECT_ID with your own project id.

1. move to `axum-test` directory.
  ```
  $ cd axum-test
  ```
1. make docker image with tag for gcp.
  ```
  $ docker build -t gcr.io/$GCP_PROJECT_ID/axum-test:latest .
  ```
1. push the image to GCP.
  ```
  $ docker push gcr.io/$GCP_PROJECT_ID/axum-test:latest
  ```

### Deploy workflows

1. execute terraform. the `vars.tfvars` contains definisions of necessary variables.
  ```
  $ terraform plan -var-file vars.tfvars
  $ terraform apply -var-file vars.tfvars
  ```
1. make sure the deployment succeeded.
  ```
  $ gcloud workflows list
  ...snip...
  ```

### Execute workflows

The workflow needs two arguments. That is `cityName` and `openWeatherApiKey`.

```
$ gcloud workflows execute sample-workflow --data="{\"cityName\":\"横浜\", \"openWeatherApiKey\":\"$OPEN_WEATHER_KEY\"}"
```

### Clean up

- execute terraform
  ```
  $ terraform destroy -var-file vars.tfvars
  ```

- delete container image from container registory.
