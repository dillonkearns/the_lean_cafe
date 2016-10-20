import {Socket} from "phoenix"
import $ from "jquery"

function createChannel(username) {
  let socket = new Socket("/socket", {params: {username: username, table_hash: roomHash()}})
  socket.connect()
  window.socket = socket
  return socket.channel(`table:${roomHash()}`, {})
}

function joinChannel(channel) {
  channel.on("new_topic", payload => {
    addTopic(payload.body)
  })

  channel.on("topics", payload => {
    console.log("::::::::topics");
    console.log(payload);
    if (payload.pollClosed) {
      closePoll()
    }
    $(`#topics`).empty()
    $(`#topics`).append(payload.topics)
  })

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

window.createChannel = createChannel
window.joinChannel = joinChannel
function getUsername() {
  return "anonymous"
}
let channel = createChannel(getUsername())
joinChannel(channel)

function reconnectAs(username) {
  socket.disconnect()
  channel = createChannel(username)
  joinChannel(channel)
}

window.reconnectAs = reconnectAs


let chatInput = document.querySelector("#topic-input")
let messagesContainer = document.querySelector("#topics")
let closePollButton = document.querySelector("#close-poll")
let topicInputForm = $(".topic-input-form")
let pollClosed = false

$('#username-input').change(function () {
  reconnectAs($('#username-input').val())
})

function submitTopic() {
  channel.push("new_topic", {body: chatInput.value})
  chatInput.value = ""
}

$('#topic-input-form').submit(function(ev) {
    ev.preventDefault()
    submitTopic()
    $('#topic-input').focus()
});

closePollButton.onclick = function () {
  channel.push("close_poll", {})
}

function closePoll() {
  $(topicInputForm).hide();
  pollClosed = true
}

function roomHash() {
  return document.querySelector("#table-id").value
}

window.romanVote = function (id) {
  if (!pollClosed) {
    channel.push("roman_vote", {topic_id: id})
  }
}

function addTopic(topicHtml) {
  $(`#topics`).append(topicHtml)
}



export default socket
