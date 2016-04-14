# backbone.bootstrap

An extension to backbone to support easily bootstrapping data for models and collections.

## Installation

Install as a bower component using `bower install backbone.bootstrap --save`.

The application will automatically bind to the page when its included as part of your javascript output.

## Usage

You can use any number of server side techniques to include the following elements into the DOM that your javascript application is included on.

```html
<script type="application/json" data-url="/api/service/endpoint/1">
	{"id": "2", "name": "john smith"}
</script>
```

All script tags with the type `application/json` and a `data-url` property and valid JSON will automatically be returned from any Backbone request that matches the url specified in the `data-url` property.

### Options

On any identified and valid script tag, other attributes can be specified in the format data-{attribute} from the list below.

* usage - (default: once) one of these values 'once', 'forever'. Determines for how long the bootstrap value will be returned.

## Contributors

Special thanks go to https://github.com/ianllewellyn and https://github.com/apjones6 for help with this library.

## History

* patch
	* Ensuring complete method is called as well as success

* 2.0.1
	* Fixing issues creating the cache key options.data is just a string rather than an object

* 2.0.0
	* Some libraries implement their own sync methods. This meant support wasn't complete. Changed internal implementation to proxy Backbone.ajax instead.

* 1.1.1
	* Fixing handling of query string urls created by backbone models/collections

* 1.1.0
	* Supporting usage option on bootstrap data for greater flexibility

* 1.0.2
	* Preventing cache items being used more than once. This will allow polling type use cases
	* Ensuring that the complete callback is called when provided

* 1.0.1
	* Preventing DOM order for bootstrap elements preventing their inclusion in cache

* 1.0.0
	* Functional bootstrap enhancements to backbone