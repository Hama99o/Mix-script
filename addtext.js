let arr = [];
function addText() {
    let text = document.getElementById('questions_hash_quick_reply').value;
    arr.push(text);
    res = document.getElementById('quick_reply').innerText = arr;
}