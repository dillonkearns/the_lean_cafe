import {Socket} from "phoenix"
import $ from "jquery"
import toastr from "toastr"

let socket

function createChannel(username) {
  socket = new Socket("/socket", {params: {username: username, table_hash: roomHash()}})
  socket.connect()
  return socket.channel(`table:${roomHash()}`, {})
}

function myUsername() {
  return $('#username-input').val() || "anonymous"
}

function highlightMyVote(lastVote) {
    $('.roman-vote-button').removeClass('highlight')
    let voteClass
    if (lastVote === '+') {
      voteClass = 'up'
    } else if (lastVote === '=') {
      voteClass = 'side'
    } else if (lastVote === '-') {
      voteClass = 'down'
    }
    $(`#vote-${voteClass}`).addClass('highlight')
}

function joinChannel(channel) {
  channel.on("new_topic", payload => {
    addTopic(payload.body)
  })
  channel.on("states", payload => {
    $('#states-group').html(payload.states_html)
  })

  channel.on("users", payload => {
    let thisUser = payload.users.find(user => user.username === myUsername())
    highlightMyVote(thisUser.last_vote)
    let otherUsers = payload.users.filter(user => user.username !== myUsername())
    renderUsernames(otherUsers)
  })

  channel.on("topics", payload => {
    if (payload.pollClosed) {
      closePoll()
    }
    $(`#topics`).empty()
    $(`#topics`).append(payload.topics)
    window.makeTopicsEditable()
  })

  channel.on('roman_result', payload => {
    toastr.options.escapeHtml = true
    toastr.options.closeHtml = `<button>${renderVote(payload.result)}</button>`
    toastr.options.closeButton = true
    toastr.info('', 'Roman Vote Results')
  })

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  window.channel = channel

    $('#username-group').addClass('has-success')
    $('#username-group').addClass('has-feedback')
}

$('#username-group').on('input', function() {
  $('#username-group').removeClass('has-success')
  $('#username-group').removeClass('has-feedback')
})

let channel = createChannel(myUsername())
joinChannel(channel)

function reconnectAs(username) {
  socket.disconnect()
  channel = createChannel(username)
  joinChannel(channel)
}

let chatInput = document.querySelector("#topic-input")
let messagesContainer = document.querySelector("#topics")
let topicInputForm = $(".topic-input-form")
let currentTopicForm = $(".current-topic-form")
let pollClosed = false

$('#username-input').change(function () {
  reconnectAs($('#username-input').val())
})

function renderVote(vote) {
  let icon
  if (vote === '+') {
    icon = 'glyphicon-thumbs-up'
  } else if (vote === '=') {
    icon = 'glyphicon-hand-left'
  } else if (vote === '-') {
    icon = 'glyphicon-thumbs-down'
  } else {
    return ''
  }
  return `<span class="glyphicon ${icon}" />`
}

function usernamesHtml(usernames) {
  return usernames.map(user => `<li>${renderVote(user.last_vote)} @${user.username}</li>`).join('')
}

function renderUsernames(usernames) {
  $('#usernames').html(usernamesHtml(usernames))
}

function submitTopic() {
  channel.push("new_topic", {body: chatInput.value})
  chatInput.value = ""
}

function vote(voteType) {
  channel.push('roman_vote', {vote: voteType})
}

function clearVotes() {
  channel.push('clear_votes')
}

window.clearVotes = clearVotes
window.vote = vote

$('#topic-input-form').submit(function(ev) {
    ev.preventDefault()
    submitTopic()
    $('#topic-input').focus()
});

window.changeState = function (toState) {
  channel.push("change_state", {to_state: toState})
}

document.querySelector("#complete-topic").onclick = function () {
  channel.push("complete_topic", {})
}

function closePoll() {
  $(topicInputForm).hide();
  $(currentTopicForm).css('visibility', 'visible');
  pollClosed = true
}

function roomHash() {
  return document.querySelector("#table-id").value
}

window.dotVote = function (id) {
  channel.push("dot_vote", {topic_id: id})
}

function addTopic(topicHtml) {
  $(`#topics`).append(topicHtml)
}

export default socket
