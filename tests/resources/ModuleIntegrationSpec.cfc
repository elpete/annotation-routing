component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();

        getController().getModuleService()
            .registerAndActivateModule( "annotation-routing", "testingModuleRoot" );

        getWireBox().autowire( this );
    }

    /**
    * @beforeEach
    */
    function setupIntegrationTest() {
        setup();
    }

}
