# Manya specific functions

module.exports = (robot) ->
  robot.respond /who are your favorite fellows?/i, (msg) ->
      msg.send "jessepollak and switz"
