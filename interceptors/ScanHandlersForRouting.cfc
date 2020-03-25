component {

    // DI
    property name="handlerService" inject="coldbox:handlerService";
    property name="router" inject="coldbox:router";

    // Settings
    property name="registeredHandlers" inject="coldbox:setting:registeredHandlers";
    property name="handlersInvocationPath" inject="coldbox:setting:HandlersInvocationPath";
    property name="registeredExternalHandlers" inject="coldbox:setting:registeredExternalHandlers";
    property name="handlersExternalLocation" inject="coldbox:setting:handlersExternalLocation";
    property name="moduleRegistry" inject="coldbox:setting:modules";

    /**
     * Parse Handler Metadata for Routing
     */
    function afterAspectsLoad() {
        // TODO: Remove the catch all route if it is the last route

        scanHandlersForRouting(
            handlers = variables.registeredHandlers.listToArray(),
            invocationPath = variables.handlersInvocationPath,
            module = ""
        );

        scanHandlersForRouting(
            handlers = variables.registeredExternalHandlers.listToArray(),
            invocationPath = variables.handlersExternalLocation,
            module = ""
        );


        variables.moduleRegistry.each( function( _, module ) {
            scanHandlersForRouting(
                handlers = module.registeredHandlers.listToArray(),
                invocationPath = module.handlerInvocationPath,
                module = module.entrypoint
            );
        } );

        // TODO: Add back in the catch all route if it existed
    }

    private function scanHandlersForRouting(
        required array handlers,
        required string invocationPath,
        required string module
    ) {
        for ( var handlerName in arguments.handlers ) {
            var handler = variables.handlerService.newHandler(
                arguments.invocationPath & "." & handlerName
            );

            var handlerMetadata = getMetadata( handler );

            if ( !handlerMetadata.keyExists( "route" ) ) {
                continue;
            }

            // ensure routes starts with `/`
            var route = left( handlerMetadata.route, 1 ) != "/" ? "/" & handlerMetadata.route : handlerMetadata.route;

            param handlerMetadata.resourceful = false;
            var isResourceful = structKeyExists( handlerMetadata, "resourceful" ) && handlerMetadata.resourceful != "false";
            if ( isResourceful ) {
                param handlerMetadata.parameterName = "id";
                param handlerMetadata.api = false;
                var isAPI = structKeyExists( handlerMetadata, "api" ) && handlerMetadata.api != "false";
                var resourceName = mid( route, 2, len( route ) - 1 );
                variables.router.resources(
                    resource = resourceName,
                    handler = handlerName,
                    parameterName = handlerMetadata.parameterName,
                    except = isAPI ? [ "new", "edit" ] : [],
                    pattern = route
                );
                continue;
            }

            var potentialActions = handlerMetadata.functions.filter( function( md ) {
                return md.access == "public";
            } );

            if ( potentialActions.isEmpty() ) {
                return;
            }

            for ( var action in potentialActions ) {
                param action.route = action.name;
                param action.method = "GET";
                var actionRoute = left( action.route, 1 ) != "/" ? "/" & action.route : action.route;

                var handlerRoute = right( route, 1 ) == "/" ? mid( route, 1, len( route ) - 1 ) : route;

                variables.router
                    .route( handlerRoute & actionRoute )
                    .withModule( arguments.module )
                    .withHandler( handlerName )
                    .withAction( { "#action.method#": action.name } )
                    .prepend()
                    .end();
            }
        }
    }

}
