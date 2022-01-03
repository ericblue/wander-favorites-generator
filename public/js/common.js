function processJsonFailure(xhr) {

    var reason = 'Unknown';

    if (xhr != null) {
        var response = null;
        if (xhr.responseText != null) {
            response = JSON.parse(xhr.responseText);
        }

        if (response != null) {
            if (response.responseType == 'FAILURE') {
                reason = response.response.reason;
                log.warn('JSON request failed due to ' + reason)

            }
        }
    }

    return reason;

}