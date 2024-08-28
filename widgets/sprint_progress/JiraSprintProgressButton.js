$('document').ready(function(){

    var boardModal = document.getElementById('JiraSprintProgressModal');
    var boardSpan = document.getElementById('JiraSprintProgressModalClose');
    var boardSelected = "";

    $(document).on('click', '#OverallBoard', function(){
        boardModal.style.display = "block";
        boardSelected = "overall"
    });

    $(document).on('click', '#AnvilBoard', function(){
        boardModal.style.display = "block";
        boardSelected = "anvil"
    });

    $(document).on('click', '#AutobotsBoard', function(){
        boardModal.style.display = "block";
        boardSelected = "autobots"
    });

    $(document).on('click', '#InfernoBoard', function(){
        boardModal.style.display = "block";
        boardSelected = "inferno"
    });

    $(document).on('click', '#BrahmaBoard', function(){
        boardModal.style.display = "block";
        boardSelected = "brahma"
    });

    var boardLink = "";
    $(document).on('click', '#continueButtonSprintProgress', function(){
        boardModal.style.display = "none";
        switch(boardSelected){
            case "overall":
                boardLink = "https://jira-nam.lmera.ericsson.se/secure/RapidBoard.jspa?rapidView=5475&view=planning";
                break;
            case "anvil":
                boardLink = "https://jira-nam.lmera.ericsson.se/secure/RapidBoard.jspa?rapidView=3299";
                break;
            case "autobots":
                boardLink = "https://jira-nam.lmera.ericsson.se/secure/RapidBoard.jspa?rapidView=5441";
                break;
            case "inferno":
                boardLink = "https://jira-nam.lmera.ericsson.se/secure/RapidBoard.jspa?rapidView=5560";
                break;
            case "brahma":
                boardLink = "https://jira-nam.lmera.ericsson.se/secure/RapidBoard.jspa?rapidView=5561";
                break;
        }
        var win = window.open(boardLink, '_blank');
        win.focus();
    });

    boardSpan.onclick = function() {
        boardModal.style.display = "none";
    }
});