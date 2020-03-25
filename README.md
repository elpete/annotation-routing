# annotation-routing

[![Master Branch Build Status](https://img.shields.io/travis/elpete/annotation-routing/master.svg?style=flat-square&label=master)](https://travis-ci.org/elpete/annotation-routing)

## Use annotations in your handlers to configure your router!

### Still WIP.  Help welcome.

Use the `route` annotation to specify a path for a handler.
Add `resourceful` to create all the resourceful routes.
Specify `parameterName` to override the default (`id`).
Add `api` to exclude `new` and `edit` routes.

Use the `route` annotation on a method to specify a path for an action.
Actions without a `route` annotation use the name of the method.
Add a `method` annotation to specify the allowed method.

Works in modules, adding routes under the module entrypoint.

### Examples

```cfc
component route="/echo" {

	/**
	 * Home page
	 */
	function index( event, rc, prc ) route="/something" {
		event.setView( "home/index" );
	}

}
```

```cfc
component route="/employees" resourceful api parameterName="employeeID" {

    function index() {
        return [ { "id": 1, "name": "John Doe" } ];
    }

}
```
