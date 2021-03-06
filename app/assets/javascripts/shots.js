$(document).ready(function() {
    var text_max = 130;
    $('#textarea_feedback').html(text_max + ' characters remaining');

    // count characters
    $('#notearea').keyup(function() {
        var text_length = $('#notearea').val().length;
        var text_remaining = text_max - text_length;

        $('#textarea_feedback').html(text_remaining + ' characters remaining');
    });

    // getting video id
    $('#attachedVideo').bind('DOMSubtreeModified', function(event) {
        _gaq.push(['_trackEvent', 'click', 'attach video','']);
        var attachedVideoDiv = document.getElementById("attachedVideo").innerHTML;
        var videoID = $(attachedVideoDiv).attr("value").split("filename")[0].replace("id\":\"", "");
        videoID = videoID.replace(/([^a-z0-9]+)/gi, '');
        var vID = document.createElement('div');
        vID.innerHTML = videoID;
        // console.log("video id: ", videoID);
        document.getElementById("video_id").appendChild(vID.firstChild);

    });

    $( "#nav-shot" ).click(function() {
     _gaq.push(['_trackEvent', 'click', 'Create happyshot Nav','']);
    });

    $( "#trigerModal" ).click(function() {
          _gaq.push(['_trackEvent', 'click', 'Create happyshot page','']);
    });

    
    });

// disable submit button while video uploads
$(document).on("upload:start", "form", function(e) {
    _gaq.push(['_trackEvent', 'upload', 'video upload starts','']);
    document.querySelector('#notify').innerHTML="Uploading video, wait please...";
    document.getElementById("create-gifVideo").disabled = true; 
    $(this).find("input[type=submit]").attr("disabled", true)
});
// enable back submit button while video upload finish
$(document).on("upload:complete", "form", function(e) {
    _gaq.push(['_trackEvent', 'upload', 'video upload complete','']);
    if (!$(this).find("input.uploading").length) {
        document.querySelector('#notify').innerHTML="Upload Done!";
        document.getElementById("create-gifVideo").disabled = false; 
        $(this).find("input[type=submit]").removeAttr("disabled")
    }
});