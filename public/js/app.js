!function($) {
    "use strict";

    var App = function() {

    };

    App.prototype.initialized = false;
    App.prototype.config = null;

    App.prototype.environmentEnum = {
        DEVELOPMENT : "DEVELOPMENT",
        TEST:  "TEST",
        PRODUCTION: "PRODUCTION",
        UNKNOWN: null
    };

    App.prototype.requestPath = function() {

        // E.g. http://localhost:3000/dashboard
        // Returns dashboard (we remove leading slash)

        return window.location.pathname.substring(1);
    }


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

            $('#generate-favorites').click(function() {

                log.info('Processing locations ' + $('#locations').val());

                var results = $.ajax({
                    type: "POST",
                    url: "generate-favorites?folder=" +  $('#folder').val() ,
                    data: $('#locations').val()
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
                    log.error('Unable to get config. Reason = ' + reason);
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
                hiddenElement.download = 'Wander_Favorites.json';
                hiddenElement.click();

                // end click download-favorites
            });



            // Load sample data

            var locations = 'New York City|Trip to the Big Apple\n';
            locations += 'Stanford University|Stanford\n'
            locations += '35.671822206844446, 139.69669206926622|Yoyogi Park, 2 Yoyogikamizonocho, Shibuya City, Tokyo, Japan\n';

            $('#locations').val(locations);


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