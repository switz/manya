messages = []

module.exports = (robot) ->
  robot.hear /(.*)/i, (msg) ->
    messages.push escape(msg.match[1])
    if messages.length > 5
      messages.shift()
  robot.respond /history/i, (msg) ->
    msg.send quote for quote in messages

