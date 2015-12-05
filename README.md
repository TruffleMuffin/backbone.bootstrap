# backbone.bootstrap

An extension to backbone to support easily bootstrapping data for models and collections.

# Installation

Install as a bower component using `bower install --save backbone.bootstrap`.

The application will automatically bind to the page when its included as part of your javascript output.

# Usage

You can use any number of server side techniques to include the following elements into the DOM that your javascript application is included on.

```html
<script type="application/json" data-url="/api/service/endpoint/1">
	{"id": "2", "name": "john smith"}
</script>
```

All script tags with the type `application/json` and a `data-url` property and valid JSON will automatically be returned from any Backbone request that matches the url specified in the `data-url` property.
