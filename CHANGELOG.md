# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Travis configuration
- Updated Repgen ENV in Dockerfile to an ARG and defaulting it to "master"
### Updated
- Split up gsplot and repgen installations in Dockerfile. Moved repgen installation
below gsplot. This allows faster subsequent builds when repgen changes but gsplot
has not (typical case). Previously, gsplot and repgen were being downloaded and
installed within the same two RUN blocks, causing extra time to reinstall gsplot
when it is not necessary

## [0.0.3] - 2018-03-19
### Updated
- Updated Repgen to v1.9

## [0.0.2] - 2018-02-22
### Updated
- README removed extra single quote in command
- Repgen updated to 1.8

## [0.0.1] - 2018-02-16
### Added
- Initial release
