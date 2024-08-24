# BOSH Boost Release

This release provides a set of tools that can be utilized across various deployments, enhancing the deployment process with additional capabilities:

- `files_creator`: A job that allows for the creation of directories and files with specified permissions and ownership and filtering by zones.
- `scripts_executor`: A job designed to execute custom scripts at various lifecycle stages of a BOSH job.
- `bosh_info`: A utility job that provides metadata and information about the BOSH environment.

## Usage

```yaml
---
name: test-boost
instance_groups:
- name: test
  azs: [z1, z2]
  instances: 1
  vm_type: default
  persistent_disk_type: default
  stemcell: default
  networks: [{name: default}]
  jobs:
  - name: files_creator
    release: boost
    properties:
      directories_to_create:
      - path: /tmp/dir-x
      - path: /tmp/dir-y
        chown: "vcap:vcap"
        chmod: "700"
      files_to_create:
      - path: /tmp/zone.txt
        azs_filters: ["z1"]
        content: |+
          hello  z1!
      - path: /tmp/zone.txt
        azs_filters: ["z2"]
        content: |+
          hello z2!
      - path: /tmp/my-script.sh
        content: |+
          #!/bin/bash

          echo "hello world!"
        chown: "vcap:vcap"
        chmod: "700"
  - name: scripts_executor
    release: boost
    properties:
      scripts_to_execute:
        # https://bosh.io/docs/job-lifecycle/
        pre-start: |
          echo pre-start $(date +%G-%m-%d\T%H:%M:%S.%N) >> /tmp/scripts_executor.log
          echo "  whoami: $(whoami)" >> /tmp/scripts_executor.log
          echo "  pwd: $(pwd)" >> /tmp/scripts_executor.log
          echo "  export: '$(export)'" >> /tmp/scripts_executor.log
        post-start:  'echo post-start $(date +%G-%m-%d\T%H:%M:%S.%N) >> /tmp/scripts_executor.log'
        post-deploy: 'echo post-deploy $(date +%G-%m-%d\T%H:%M:%S.%N) >> /tmp/scripts_executor.log'
        pre-stop:    'echo pre-stop $(date +%G-%m-%d\T%H:%M:%S.%N) >> /tmp/scripts_executor.log'
        post-stop:   'echo post-stop $(date +%G-%m-%d\T%H:%M:%S.%N) >> /tmp/scripts_executor.log'
  - name: bosh_info
    release: boost

releases:
- name: boost
  version: latest

stemcells:
- alias: default
  os: ubuntu-jammy
  version: latest

update:
  canaries: 1
  canary_watch_time: 30000-1200000
  max_in_flight: 1
  serial: false
  update_watch_time: 5000-1200000

```
