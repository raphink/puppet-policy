## 0.7.4
### Changes

* MCollective agent: add type parameter for specinfra compat
* Initalize Puppet settings

## 0.7.3
### Changes

* Fix provider test in package auto_spec

## 0.7.2
### Changes

* Do not use the wrap parameter

## 0.7.1
### Changes

* Make sure spec_dir exists

## 0.7.0
### Changes

* Merged code from puppet-policy_compiler (thanks to Hunger Haugen)
* Remove agent-side catalog terminus

## 0.6.0
### Changes

* Add Group auto_spec plugin
* Add Host auto_spec plugin
* Add basic unit tests and coverage for auto_spec plugins

## 0.5.3
### Changes

* Improve documentation on auto_spec plugins

## 0.5.2
### Changes

* Fix User plugin when user is absent
* Allow several auto_spec plugins for the same resource type
* Add some debug
* Fix spec MCollective agent when calling RSpec.configure

## 0.5.1
### Changes

* Improve doc for auto_spec plugins

## 0.5.0
### Changes

* Make auto_spec pluggable

## 0.4.2
### Changes

* Fix serverspec parameter in policy class

## 0.4.1
### Changes

* Create the two levels of directories required for specs

## 0.4.0
### Changes

* Renamed module as puppet-policy
* Fixed paths in MCollective agent

## 0.3.0
### Changes

* Simplify report terminus by putting everything in :vardir/spec/server
* Add a new "spec" class to setup directories

## 0.2.1
### Changes

* Some metadata fixes

## 0.2.0
### Changes

* Automatically generate serverspec code from Puppet catalog in the report indirector
* Port code to serverspec/specinfra v2
