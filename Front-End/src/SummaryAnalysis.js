/* eslint-disable */
function showTime() {
  document.getElementById("currentTime").innerHTML = new Date().toUTCString();
}
showTime();
setInterval(function () {
  showTime();
}, 1000);
function getSymptoms() {
  //Get history from txt file
  document.getElementById("symptom").innerHTML = new XMLHTTPRequest();
  client.open("GET", "patientID".txt);
}
function printSymptoms() {
  getSymptoms();
  window.onload = function () {
    function converttxttoArray() {
      //Convert history to array
      var reader =
        window.XMLHttpRequest != null
          ? new XMLHttpRequest()
          : new ActiveXObject("Microsoft.XMLHTTP");
      reader.open("GET", "patientID".txt, false);
      reader.onload = function () {
        var stop_list = this.responseText.split(/\n+/); //Output array line by line
        var re = /,/;
        var headers = stop_list.shift().split(re);
        var index = headers.indexOf("stop_name");
        var res = stop_list.map(function (val, key) {
          return val.split(re)[index];
        });
        console.log(res);

        var text = "";
        var i;
        for (i = 0; i < stop_list.length; i++) {
          text += res[i] + "<br>";
        }
        console.log(text);
        document.body.innerHTML = text;
      };
      reader.send();

      /* There may be a flag worth performing special activity for.
    Like, IDK, "end report for [date]".*/
    }
    converttxttoArray("stops.txt");
  };
}
const fileInput = document.getElementById("file-input");
const fileContentDisplay = document.getElementById("file-content");
const messageDisplay = document.getElementById("message");

fileInput.addEventListener("change", handleFileSelection);

function handleFileSelection(event) {
  const file = event.target.files[0];
  fileContentDisplay.textContent = ""; // Clear previous file content
  messageDisplay.textContent = ""; // Clear previous messages

  // Validate file existence and type
  if (!file) {
    showMessage("No file selected. Please choose a file.", "error");
    return;
  }

  if (!file.type.startsWith("text") || !file.type.startsWith("txt")) {
    showMessage("Unsupported file type. Please select a text file.", "error");
    return;
  }

  // Read the file
  const reader = new FileReader();
  reader.onload = () => {
    fileContentDisplay.textContent = reader.result;
  };
  reader.onerror = () => {
    showMessage("Error reading the file. Please try again.", "error");
  };
  reader.readAsText(file);
}

// Displays a message to the user
function showMessage(message, type) {
  messageDisplay.textContent = message;
  messageDisplay.style.color = type === "error" ? "red" : "green";
}
