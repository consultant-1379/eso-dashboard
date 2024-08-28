$('document').ready(function(){

    var bugModal = document.getElementById('JiraInfoModal');
    var bugSpan = document.getElementById("JiraInfoModalClose");

    $(document).on('click', '#bugCounter', function(){
        bugModal.style.display = "block";
    });

    $(document).on('click', '#continueButtonBugs', function(){
        bugModal.style.display = "none";
        var win = window.open("https://jira-nam.lmera.ericsson.se/issues/?filter=72802", '_blank');
        win.focus();
    });

    bugSpan.onclick = function() {
        bugModal.style.display = "none";
    }
});