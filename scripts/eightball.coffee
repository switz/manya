# The Magic Eight ball
#
# eightball <query> - Ask the magic eight ball a question
#

ball = [
  "Do ruby programmers wear glasses and watch anime?",
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes – definitely",
  "You may rely on it",
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Signs point to yes",
  "Yes",
  "Reply hazy, try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again",
  "Don't count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful",
  "Exception: outlook not good."
]

module.exports = (robot) ->
  robot.respond /(eightball|8ball|question)(.*)/i, (msg) ->
    msg.reply msg.random ball