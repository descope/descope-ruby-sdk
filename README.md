Descope SDK for Python


The Descope SDK for Ruby provides convenient access to the Descope user management and authentication API for a backend written in Ruby. You can read more on the Descope Website.



# Descope SDK for Python

The Descope SDK for python provides convenient access to the Descope user management and authentication API
for a backend written in python. You can read more on the [Descope Website](https://descope.com).

## Requirements

The SDK supports Ruby 3.2 and above.

## Installing the SDK

Install the package with:

```bash
bundle install descope
```


## Setup

A Descope `Project ID` is required to initialize the SDK. Find it on the
[project page in the Descope Console](https://app.descope.com/settings/project).

```ruby
require 'descope'

# Initialized after setting the DESCOPE_PROJECT_ID env var
descope_client = Descope::Client.new(
  {
    project_id: dev_project_id,
    management_key: ENV['MGMT_KEY']
  }
)
