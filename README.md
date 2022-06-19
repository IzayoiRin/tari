# tari

Target IDF

## Environment

### Set config from Env

- Env configure key:

`VERITAS_APPLICATION_SETTINGS`

- Support config protocols:

| Protocol | Pattern             | Example                     |
|----------|---------------------|-----------------------------|
| Module   | module:module-path  | `moudel:conf.settings`      |
| Json     | json:json-file-path | `moudel:conf/settings.json` |
| URL      | url:setting-url     | `url:http://conf/settings`  |

## Error Status

- No exception: `0x000000`

- Veritas api errors

| Module | Code       | Description                     |
|--------|------------|---------------------------------|
| conf   | `0x000001` | api unknown config protocol     |
| conf   | `0x000002` | api unsupported config protocol |
| conf   | `0x000003` | api config parse exception      |
