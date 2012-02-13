# imgio: your friendly image asset resizing service

## Usage

imgio helps you resizing images along the lines of [src.sencha.io](http://www.sencha.com/learn/how-to-use-src-sencha-io/). In short: add a prefix to an image URL, and get the image resized to whatever size you need. imgio will never size up an image though: what you'll get instead is 
an image matching the requested ratio.

imgio creates PNG and JPEG output files, and supports a plethora of input formats - everything RMagick handles.

## When it takes a bit longer...

...to fetch the images from their respective sources, then you will be glad that @Overbyrd implemented sinatra async mode. This mode,
which is the default on ruby 1.9 installations (and, btw, is not available on Ruby 1.8.7) lets your imgio instance fetch a number
of images in parallel. You could do this by deploying multiple imgio instances behind an apache or nginx proxy - but this way your
CPU is used more effectively (and a free Heroku instance looks much better now.)

### HTML

The following `<img>` tag will always be 120px wide and 90px high. The requested image will be rescaled to fill that size. Overflowing parts of the image will be cut off.

    <img src="http://<yourserver>/fill/120/90/http://www.google.de/images/srpr/logo3w.png" width="120" height="90">
    </img>

<img src="http://imgio.heroku.com/fill/120/90/http://www.google.de/images/srpr/logo3w.png" width="120" height="90">
</img>

The requested image will be rescaled to fit completely into the requested size. Empty parts are filled
in white (JPEG) or transparent (PNG).

    <img src="http://<yourserver>/fit/120/90/http://www.google.de/images/srpr/logo3w.png" width="120" height="90">
    </img>

<img src="http://imgio.heroku.com/fit/png/120/90/http://www.google.de/images/srpr/logo3w.png" width="120" height="90">
</img>

### Things that automatically scale its content. (UIImageView, android.widget.ImageView)

Such views allow you to scale & fill properly by themselves. However, escecially on mobile 
platforms scaling down the image to whatever is actually needed still helps with not 
wasting precious memory and CPU resources. To do so, just request `http://<yourserver>/120/90/http://www.google.de/images/srpr/logo3w.png` instead.
  
<img src="http://imgio.heroku.com/120/90/http://www.google.de/images/srpr/logo3w.png" style="border: 1px solid black">
</img>

## The full URL syntax

The full URL syntax is `http://<yourserver>/[mode]/[format[quality]]/width/[height]/uri`

* **mode**: "fit", "fill", "scale_down", optional, defaults to "scale_down"
* **format**: "png" or "jpg", optional, defaults to "jpg"
* **quality**: the quality used when generating jpg, optional, defaults to 85
* **width**: the width of the resulting image
* **height**: the height of the resulting image, optional, defaults to whatever height would match the original image's aspect ratio.
* **uri**: the URI to fetch the original image from

# Deployment

## Run

    bundle install
    bundle exec thin start

## How it works

This script parses the URL you pass it, fetches the image at the URL, uses RMagick to convert the image, and spits out the result. Pretty basic stuff, actually.

### Caching is important

The HTTP response has the proper cache headers set to cache the result for 1 day (on default). That means
each requested image is built only a few times per day - assuming your webserver is configured to use a cache like [varnish](https://www.varnish-cache.org/). Hint: Heroku runs its instances behind a varnish cache.

# How to deploy

This is a simple sinatra application. Should work out of the box using the usual sinatra deployment options.
[How to deploy on heroku](http://blog.heroku.com/archives/2009/3/5/32_deploy_merb_sinatra_or_any_rack_app_to_heroku/)

# Help improve this script (if you feel like doing so)

- Clone. Extend. Fix. Send pull request.

Improvement areas are:

- **error handling**: What happens if an URL is unresponsive? We certainly should not cache a 404 or something
  similar, but we should not request the same URL over and over again. Any ideas welcome, especially when
  they do not need a database or some other kind of "local" storage. 
- **testing**: @sebastianspier contributed some tests that do real work, i.e. actually fetch images off the
  net (thanks!). It would be nice though to have a) a web mock which just fake-delivers images, and b) some
  code that actually compares generated images with expected ones. 

## Development

* Make sure you have ImageMagick installed
* <strike>Imgio only works with ruby >= 1.9</strike> Works with ruby 1.8.7 and ruby 1.9.2.
* Bundler is used for dependency management, so use `$ bundle install` to fetch the needed dependencies
* You can run the included tests with `$ rake`

## [Contributors](https://github.com/radiospiel/imgio/contributors)

* @radiospiel
* @sebastianspier
* @Overbryd
