# crul

This is a fork of the original [crul](https://github.com/porras/crul) by [Sergio Gil](https://github.com/porras):

> Crul is a [curl](http://curl.haxx.se/) replacement, that is, it's a command line
HTTP client. It has fewer features and options, but it aims to be more user
friendly. It's heavily inspired by
[httpie](https://github.com/jakubroztocil/httpie). It's written in the [Crystal](http://crystal-lang.org/) language.

## Installation

TODO: Write installation instructions here

## Usage

    Usage: crul [method] URL [options]

    HTTP methods (default: GET):
        get, GET                         Use GET
        post, POST                       Use POST
        put, PUT                         Use PUT
        delete, DELETE                   Use DELETE

    HTTP options:
        -d DATA, --data DATA             Request body
        -d @file, --data @file           Request body (read from file)
        -H HEADER, --header HEADER       Set header
        -a USER:PASS, --auth USER:PASS   Basic auth
        -c FILE, --cookies FILE          Use FILE as cookie store (reads and writes)

    Response formats (default: autodetect):
        -j, --json                       Format response as JSON
        -x, --xml                        Format response as XML
        -p, --plain                      Format response as plain text

    Other options:
        -h, --help                       Show this help
        -V, --version                    Display version

## Examples

### GET request

    $ crul http://httpbin.org/get?a=b
    HTTP/1.1 200 OK
    Server: nginx
    Date: Wed, 11 Mar 2015 07:57:33 GMT
    Content-type: application/json
    Content-length: 179
    Connection: keep-alive
    Access-control-allow-origin: *
    Access-control-allow-credentials: true

    {
      "args": {
        "a": "b"
      },
      "headers": {
        "Content-Length": "0",
        "Host": "httpbin.org"
      },
      "origin": "188.103.25.204",
      "url": "http://httpbin.org/get?a=b"
    }

### PUT request

    $ crul put http://httpbin.org/put -d '{"a":"b"}' -H Content-Type:application/json
    HTTP/1.1 200 OK
    Server: nginx
    Date: Wed, 11 Mar 2015 07:58:54 GMT
    Content-type: application/json
    Content-length: 290
    Connection: keep-alive
    Access-control-allow-origin: *
    Access-control-allow-credentials: true

    {
      "args": {},
      "data": "{\"a\":\"b\"}",
      "files": {},
      "form": {},
      "headers": {
        "Content-Length": "9",
        "Content-Type": "application/json",
        "Host": "httpbin.org"
      },
      "json": {
        "a": "b"
      },
      "origin": "188.103.25.204",
      "url": "http://httpbin.org/put"
    }

## Development

TODO: Write development instructions here

## Roadmap

- Continue from where the original repo left off
- Implement new features

## Contributing

1. Fork it (<https://github.com/your-github-user/crul/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Sergio Gil](https://github.com/porras) - author
- [Agustin Arce](https://github.com/aarcex3) - maintainer
