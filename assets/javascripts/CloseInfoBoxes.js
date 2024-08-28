$('document').ready(function(){

    var bugModalTest = document.getElementById('JiraInfoModal');
    var boardModalTest = document.getElementById('JiraSprintProgressModal');

    window.onclick = function(event) {
        if (event.target == bugModalTest) {
            bugModalTest.style.display = "none";
            console.log("bug window clicked")
        }else if (event.target == boardModalTest){
            boardModalTest.style.display = "none";
            console.log("board window clicked")
        }
    }
});