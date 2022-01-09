!function($) {
    "use strict";

    var App = function() {

    };

    App.prototype.initialized = false;
    App.prototype.importFinished = false;
    App.prototype.config = null;

    App.prototype.environmentEnum = {
        DEVELOPMENT : "DEVELOPMENT",
        TEST:  "TEST",
        PRODUCTION: "PRODUCTION",
        UNKNOWN: null
    };

    App.prototype.getWebSocketUrl = function() {


        var location = window.location;
        var websocket_url = '';

        if (location.protocol === "https:") {
            websocket_url = "wss:";
        } else {
            websocket_url = "ws:";
        }
        websocket_url += "//" + location.host;
        websocket_url += location.pathname + "ws";

        return websocket_url;

    },

    App.prototype.connectWebSockets = function(host, responseCallback) {

        log.debug('Connecting to WebSockets');

        try {

            // e.g. "ws://localhost:8000/websockets";
            $.App.socket = new WebSocket(host);

            log.debug("Socket readyState = " + $.App.socket.readyState);

            $.App.socket.onopen = function() {
                log.debug('Socket Status: ' + $.App.socket.readyState + ' (open)');

            }

            $.App.socket.onmessage = function(msg) {

                // Process message with supplied callback function
                responseCallback(msg);


            }

            $.App.socket.onclose = function() {
                log.debug('Socket Status: ' + $.App.socket.readyState + ' (Closed)');
            }

        } catch (exception) {
            log.debug('Error' + exception);
            raiseError('Could not connect to Web Socket server!');
        }

    },


        App.prototype.requestPath = function() {

        // E.g. http://localhost:3000/dashboard
        // Returns dashboard (we remove leading slash)

        return window.location.pathname.substring(1);
    },

    //
    // Sample usage:
    //
    //     async function doIt() {
    //         for (let i = 0; i < 10; ++i) {
    //             await $.App.wait(1000);
    //             console.log(i);
    //         }
    //         console.log("Loop execution finished!)");
    //     }
    //
    // doIt();

    App.prototype.wait = function(milisec) {
        return new Promise(resolve => {
            setTimeout(() => { resolve('') }, milisec);
        })
    },

    App.prototype.getEnvironment = function() {
        var config = JSON.parse(localStorage.getItem('config'));
        if (config == null) {
            return $.App.environmentEnum.UNKNOWN;
        } else {
            if (config.environment == $.App.environmentEnum.DEVELOPMENT) {
                return $.App.environmentEnum.DEVELOPMENT;
            } else if (config.environment == $.App.environmentEnum.TEST) {
                return $.App.environmentEnum.TEST;
            } else if (config.environment == $.App.environmentEnum.PRODUCTION) {
                return $.App.environmentEnum.PRODUCTION;
            } else {
                return $.App.environmentEnum.UNKNOWN;
            }
        }
    }


        // For future use
        App.prototype.getConfiguration = function(callback) {

            if ($.App.user != null) {
                callback($.App.config);
            } else {

                var config = $.getJSON('/api/configuration');

                config.done(function(data) {
                    log.info('Loaded config data')
                    $.App.config = data;

                    callback($.App.config);

                });

                config.fail(function(xhr, status, error) {
                    var reason = processJsonFailure(xhr);
                    log.error('Unable to get config. Reason = ' + reason);
                });
            }
        },

        App.prototype.loadSampleData = function() {


            var locations = 'New York City|Trip to the Big Apple\n';
            locations += 'Stanford University|Stanford\n'
            locations += '35.671822206844446, 139.69669206926622|Yoyogi Park, 2 Yoyogikamizonocho, Shibuya City, Tokyo, Japan\n';

            $('#locations').val(locations);


        },

        App.prototype.generateImportId = function() {

            return Math.random().toString(36).substr(2, 9);

        } ,

        App.prototype.addLocationsToInput = function(locations) {


            // Create location list for textarea in the format of
            // latitude, longitude | location title
            // for processed kml  file

            var locationInputData = '';

            locations.forEach((location) => {
                console.log(location);
                var entry = location.latitude + ',' + location.longitude;
                entry += '|' + location.name;

                locationInputData += entry + '\n';
            });

            $('#locations').val(locationInputData);

        },

        App.prototype.init = function() {

            log.enableAll();
            //log.setLevel('debug');
            log.debug('Initialized App JS');


            // $.App.getConfiguration(function(config){
            //     // Cache config so JS controllers can take action based on test|live mode
            //     // Save so getEnvironment can read config - don't forget to cache!
            //
            //     log.debug("App environment = " + $.App.getEnvironment());
            //     localStorage.setItem('config', JSON.stringify(config));
            //
            // });

            // Init buttons

            $('#copy-clipboard').hide();
            $('#download-favorites').hide();

            // Init fields

            $('#folder').val('MyFolderName');

            // Register buttons

            $('#import-kml').click(function() {

                // var formData = new FormData();
                // formData.append('file', $('#file')[0].files[0]);

                var fd = new FormData();
                var files = $('#file')[0].files;

                // Check file selected or not
                if(files.length > 0 ) {
                    fd.append('file', files[0]);

                    var results = $.ajax({
                        type: "POST",
                        url: "import-kml",
                        data: fd,
                        contentType: false,
                        processData: false
                    });

                    results.done(function(data) {


                        if (data.status == 'SUCCESS') {
                            log.info('Finished uploading KML, response = ' + JSON.stringify(data));

                            var successMessage = 'Imported a total of ' + data.total_locations + ' locations.  ';
                            successMessage += 'Click <i>Generate Favorites</i> to convert these locations to favorites.';

                            Swal.fire(
                                'Success',
                                successMessage,
                                'success'
                            );

                            $.App.addLocationsToInput(data.locations);


                        }  else if (data.status == 'FAILURE') {

                            Swal.fire(
                                'Error',
                                'Reason = ' + data.error_message,
                                'error'
                            );

                        } else {

                            Swal.fire(
                                'Error',
                                'An unknown error has occurred!  Return status != SUCCESS.',
                                'error'
                            );

                        }

                    });

                    results.fail(function(xhr, status, error) {
                        var reason = processJsonFailure(xhr);
                        log.error('Unable to import kml. Reason = ' + reason);
                        Swal.fire(
                            'Error',
                            'Unable to import kml. Reason = ' + reason,
                            'error'
                        )
                    });

                } else {

                    // No files selected

                    Swal.fire(
                        'No files uploaded',
                        'You must select a file to upload.',
                        'warning'
                    )
                }

                // end click import-kml

            });

            $('#generate-favorites').click(function() {

                log.info('Processing locations ' + $('#locations').val());

                var importId = $.App.generateImportId();

                // REST call to generate favorites

                var params = {
                    folder : $('#folder').val(),
                    import_id : importId
                }

                var qs = Object.keys(params)
                    .map(key => `${key}=${params[key]}`)
                    .join('&');

                var results = $.ajax({
                    type: "POST",
                    url: 'generate-favorites?' + qs,
                    //url: 'test-import-progress?' + qs,
                    data: $('#locations').val()
                });


                // WebSocket to get status
                var wsUrl = $.App.getWebSocketUrl() + '/import_status?import_id=' + importId;
                $.App.connectWebSockets(wsUrl, function(msg) {

                    log.info('Got message ' + msg.data);

                    var status = JSON.parse(msg.data);

                    if (typeof status[importId] !== 'undefined') {

                        // Check if import job is still in progress


                        var total_locations = status[importId]['total_locations'];
                        var current_location = status[importId]['current_location'];

                        if (typeof current_location !== 'undefined') {
                            var response = 'Currently processing location ' + current_location + ' out of ' + total_locations + ' locations.';

                            document.getElementById("progress-bar").innerHTML = response;

                        }

                        if (current_location >= total_locations) {
                            $.App.socket.close();
                            $.App.importFinished = true;
                            Swal.close();
                        }

                    } else {
                        console.log('Could not find import id, closing socket...');
                        $.App.socket.close();
                        $.App.importFinished = true;
                    }


                });

                // Get import status poll

                async function getImportStatus() {

                    $.App.importFinished = false;

                    for (let i = 0; i < 30; ++i) {
                        await $.App.wait(1000);

                        // If status web socket is open, keep getting status
                        if ($.App.socket.readyState == 1) {
                            console.log('Socket is open, requesting import status');
                            $.App.socket.send('');
                        } else {
                            console.log('Socket is closed, aborting getImportStatus()');
                            break;
                        }

                        //console.log(i);
                    }
                    console.log("Get import status finished!)");
                }

                getImportStatus();

                Swal.fire({
                    title: 'Generating Wander Favorites',
                    timerProgressBar: true,
                    html: '<div class=\'loader mx-auto\'></div><br><div id=\'progress-bar\'>Processing favorites...</div><p></p>',
                    showConfirmButton: false
                }).then((result) => {
                    if (result.dismiss) {

                        $.App.socket.close();

                        Swal.fire({
                            icon: 'warning',
                            title: 'Aborted',
                            text: 'Wander Favorites not generated!',
                            showConfirmButton: false,
                            timer: 3500
                        })

                    }
                });


                results.done(function(data) {
                    log.info('Finished generating favorites, response = ' + JSON.stringify(data));

                    if (data.total_favorites >= 1) {

                        $('#favorites').val(data.favorites_json);

                        var message = 'Processed ' + data.total_favorites + ' locations.';

                        if (data.total_errors) {

                            message += ' Skipped ' + data.total_errors + ' entries due to format errors';

                        }

                        // Show buttons

                        $('#copy-clipboard').show();
                        $('#download-favorites').show();

                        Swal.fire({
                            icon: 'success',
                            title: 'Wander Favorites Generated',
                            text: message,
                            showConfirmButton: false,
                            timer: 3500
                        })


                    } else {
                        $('#favorites').val();

                        var message = 'Processed 0 locations.';


                        Swal.fire({
                            icon: 'warning',
                            title: 'No Wander Favorites Generated',
                            text: message,
                            showConfirmButton: false,
                            timer: 3500
                        })

                    }




                });

                results.fail(function(xhr, status, error) {
                    var reason = processJsonFailure(xhr);
                    log.error('Unable to get favorites. Reason = ' + reason);
                });


                // end click generate-favorites
            });


            $('#copy-clipboard').click(function() {


                var copyText = document.getElementById("favorites");

                /* Select the text field */
                copyText.select();
                copyText.setSelectionRange(0, 99999); /* For mobile devices */

                /* Copy the text inside the text field */
                navigator.clipboard.writeText(copyText.value);

                Swal.fire({
                    icon: 'success',
                    title: 'Wander Favorites Generated',
                    text: 'Copied to clipboard',
                    showConfirmButton: false,
                    timer: 2500
                })


                // end click copy-clipboard
            });


            $('#download-favorites').click(function() {

                var textToSave = $('#favorites').val();
                var hiddenElement = document.createElement('a');

                hiddenElement.href = 'data:attachment/text,' + encodeURI(textToSave);
                hiddenElement.target = '_blank';
                hiddenElement.download = 'Wander_Favorites_' + $('#folder').val() + '.json';
                hiddenElement.click();

                // end click download-favorites
            });



            // Load sample data


            $.App.loadSampleData();

            log.debug('Getting WebSocket URL for future connections: ' + $.App.getWebSocketUrl());

            $.App.initialized = true;

        },
        // init
        $.App = new App, $.App.Constructor = App
}(window.jQuery),

// initializing
function($) {
    "use strict";

    $.App.init();
}(window.jQuery);