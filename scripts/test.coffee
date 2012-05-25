module.exports = (robot) ->
  robot.respond /room/i, (msg) ->
    msg.send "#{msg.message.user.room}"
