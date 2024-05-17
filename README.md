# Ranger Worker

## Overview
Worker script for querying SQS queue and executing component script.
Receives YAML message and execute task component accordingly.

### Glossary
- Component: Executable module
- Task: Contains component to execute and its parameter 
- Job: Contains tasks that need to be executed 


## Requiremd Gems
- aws-sdk-sqs
- aws-sdk-s3

## Usage
```shell
$ ruby ruby-worker.rb
missing argument: Mode is required
Usage: ruby-worker.rb [options]
    -m, --mode MODE                  Set operation mode
    -d, --debug                      Show debug logs
    -h, --help                       Prints this help
```
### Config
Modify `config/config.yml` for configuration
- sqs_url: List of AWS SQS Url for each mode
- bucket: List of AWS Bucket
- Components: List of components and mode that is able to execute it

example:
```yaml
sqs_url:
    mode1: [Mode 1 SQS Url]
    mode2: [Mode 2 SQS Url]
    ...

bucket:
    data: data_bucket
    job: job_bucket

components:
    component1: mode1
    component2: mode1
    component3: modeN
    ...
```

#### Adding Components
To add components:
- Add Python script `{component}.py` at `./components/`
- Add **components** entry at [`./config/config.yml`](#config)

### Job Message
Job message consists of:
- Job details
    - ID
    - Data
    - Total/Current Task
- Task Lists

exmaple:
```yaml
job:
    id: [Job ID]
    data:
        id: [Data ID]
        name: [Data Name]
        type: [Data Type]
    total_task: N
    current_task: 0

tasks:
    task0:
        component1:
            param1: [Example]
            ...
    task1:
        componentN:
            ...
    ...
```


### Example
```shell
$ ruby ruby-worker.rb --mode mode1
I, [2024-05-17 16:53:41 #301974]  INFO -- : ===== Starting 'mode1' worker =====
```
