component {

    this.title = "annotation-routing";
    this.description = "Use annotations in your handlers to configure your router!";
    this.version = "1.0.0";
    this.cfmapping = "annotationRouting";
    this.dependencies = [];

    function configure() {
        interceptors = [
            { class = "#moduleMapping#.interceptors.ScanHandlersForRouting" }
        ];
    }

}
