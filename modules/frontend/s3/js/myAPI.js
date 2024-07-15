(function myScopeWrapper($) {
    $(function onDocReady() {
        alert('Welcome');
        $('#enterBtn').click(handleRequestClick);

        if (!_config.api.invokeUrl) {
            $('#noApiMessage').show();
        }
    });

    function handleRequestClick() {
        var field1 = $('#field1').val();
        var field2 = $('#field2').val();
        execute(field1, field2);
    }

    function execute(field1_var, field2_var) {
        $.ajax({
            method: 'POST',
            url: _config.api.invokeUrl + '/execution',
            headers: {

            },
            data: JSON.stringify({
                field1: field1_var,
                field2: field2_var
            }),
            contentType: 'application/json',
            success: completeRequest,
            error: completeRequest
        });
    }

    function completeRequest(result) {
        console.log('Response received from API: ', result);
        displayUpdate(result.Response);
    }

    function displayUpdate(text) {
        $('#updates').append($('<li>' + text + '</li>'));
    }

}(jQuery));
