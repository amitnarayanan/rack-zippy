## 1.1.1-pre / Unreleased
- Add handling of font files with extensions: woff, woff2, ttf, eot, otf
  ([#9](https://github.com/eliotsykes/rack-zippy/issues/9))
- Handle flash .swf file extension ([#20](https://github.com/eliotsykes/rack-zippy/issues/20))

## 1.1.0 / 2014-01-26
- rack-zippy no longer blocks requests for assets that it cannot find on the filesystem. These
  requests are now passed on to the app. ([#7](https://github.com/eliotsykes/rack-zippy/issues/7))

## 1.0.1 / 2013-09-06
-  Fix error on request for assets root dir (fixes [#2](https://github.com/eliotsykes/rack-zippy/issues/2))
-  Add MIT license to gemspec (fixes [#1](https://github.com/eliotsykes/rack-zippy/issues/1))

## 1.0.0 / 2013-08-22

Production-ready release

-  Only set years-old cache-friendly last-modified header on assets with max-age of at least 1 month

## 0.1.0 / 2013-08-21

Initial release
