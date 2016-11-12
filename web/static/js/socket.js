import {Socket} from "phoenix"
import $ from "jquery"
import toastr from "toastr"
import clipboard from "clipboard"
import moment from "moment"

new clipboard('.btn')

let socket

function getAvatar() {
  return $('#user-nickname').data('avatar')
}

function createChannel(username) {
  let params
  if (username && username !== "") {
    params = {username: username, avatar: getAvatar(), table_hash: roomHash()}
  } else {
    params = {table_hash: roomHash()}
  }
  socket = new Socket("/socket", {params: params})
  socket.connect()
  return socket.channel(`table:${roomHash()}`, {})
}

function myUsername() {
  return $('#user-nickname').val()
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
  channel.on('countdown_to', payload => {
    window.countdown_to = payload.countdown_to
  })

  channel.on('username', payload => {
    window.username = payload.username
  })

  channel.on("new_topic", payload => {
    addTopic(payload.body)
  })
  channel.on("states", payload => {
    $('#states-group').html(payload.states_html)
  })

  channel.on("users", payload => {
    let thisUser = payload.users.find(user => user.username === window.username)
    highlightMyVote(thisUser.last_vote)
    let otherUsers = payload.users.filter(user => user.username !== window.username)
    renderUsernames(otherUsers)
  })

  channel.on("topics", payload => {
    showFormsForState(payload.state)
    $('.topics').empty()
    $('#topics-incomplete').append(payload.incomplete)
    $('#topics-complete').append(payload.complete)
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

function avatarHtml(avatar) {
  return `<img src="${avatar}" class="img-circle" style="max-width: 35px;"/>`
}

function usernamesHtml(usernames) {
  return usernames.map(user => `<li>${renderVote(user.last_vote)} ${avatarHtml(user.avatar)}&nbsp;${user.username}</li>`).join('')
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

function topicVote(voteType) {
  channel.push('topic_vote', {vote: voteType})
}

window.topicVote = topicVote

function clearVotes() {
  channel.push('clear_votes')
}

window.clearVotes = clearVotes

function startTimer() {
  console.log('startTimer')
  channel.push('start_timer')
}

window.startTimer = startTimer
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

function showFormsForState(state) {
  if (state === 'brainstorm') {
    $(".topic-input-form").show()
  } else {
    $(".topic-input-form").hide()
  }

  if (state === 'discuss') {
    $(".current-topic-form").show()
  } else {
    $(".current-topic-form").hide()
  }
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

function startTimerRenderLoop() {
  setInterval(function () {
    renderTimerIfSet()
  }, 100)
}

function renderTimerIfSet() {
  if (window.countdown_to) {
    let secondsRemaining = moment(window.countdown_to).diff(moment(), 'seconds')
    if (secondsRemaining < 0) {
      renderTimeRemaining(0, 0)
    } else {
      let minutes = parseInt(secondsRemaining / 60)
      let seconds = parseInt(secondsRemaining % 60)

      renderTimeRemaining(minutes, seconds)
    }
  }
}

function renderTimeRemaining(minutes, seconds) {
  $('#timer').text(`${minutes}:${zeroPad(seconds)}`)
}

function zeroPad(n) {
  return n < 10 ? "0" + n : n
}

startTimerRenderLoop()

export default socket
