# Grafana Notice

Bema uses a hardened wrapper based on:

`grafana/grafana:13.1.0@sha256:121a7a9ece6dc10b969f1f96eed64b4f07dfac0d0b8abc070f7cb83bbde86f63`

Upstream project:

Grafana

Source repository:

`https://github.com/grafana/grafana`

Primary upstream license:

GNU Affero General Public License, version 3 only (`AGPL-3.0-only`)

Bundled libraries, plugins and operating-system packages retain their respective
upstream licenses and notices.

The Bema wrapper:

- upgrades available Alpine packages
- removes unused bundled Elasticsearch and Zipkin data-source plugins
- does not modify the Grafana executable
- retains the upstream runtime user and entrypoint

The upstream source, copyright statements and license obligations remain
applicable.

Review this notice whenever the Grafana version, digest, wrapper Dockerfile or
bundled component set changes.
