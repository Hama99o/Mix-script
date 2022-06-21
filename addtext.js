let arr = [];
function addText() {
    let text = document.getElementById('text').value;
    arr.push(text);
    res = document.getElementById('result-text').innerText = arr;
}

{/* <input type="text" id="text" placeholder="Enter a text" />
<input type="submit" onclick="addText()" />

<p id="result-text"></p>  */}