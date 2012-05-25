#
# Allows storing and scoring user quotes
# Keeps a short history of the past 10 lines in chat, which users can
# add to DB of quotes
#
# Usage:
# quote that - enters a conversation with the sender about which statement in the history to quote
# quote <user> - like 'quote that', but only prompts quotes in history said by user
# quotes info - give information about quotes
# tell quote - tell a random quote
# tell <user> quote - tell a quote from <user>
# tell quote <id> - tell the quote with id <id>
#

# quote objects contain a score, an id, the speaker, and the quote text

class QuoteServer
  constructor: (@robot) ->
    @history = []
    @quotes = []
    @currentConversations = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.quotes
        @quotes = @robot.brain.data.quotes

  info: (msg) ->
    speakers = (x.speaker for x in @quotes)
    uniques = []
    (uniques.push x) for x in speakers when not (x in uniques)
    msg.send "#{@quotes.length} quote#{if @quotes.length is 1 then "" else "s"}
 from #{uniques.length} user#{if uniques.length is 1 then "" else "s"}"

  addToHistory: (msg) ->
    if msg.message.user.room?
      @history.push msg
      if @history.length > 10
        @history.shift()

  tell: (msg) ->
    formatQuote = (q) ->
      "#{q.speaker}: \"#{q.text}\""
    formatInfo = (q) ->
      "Quote ##{q.id} with a score of #{q.score}"
    responses = []
    matches = msg.match
    if matches[1] is "quote"
      if matches[2] isnt ""
        id = parseInt(matches[2], 10)
        if not isNaN(id) and (-1 < id < @quotes.length)
          responses.push (formatQuote @quotes[id])
          responses.push (formatInfo @quotes[id])
        else if isNaN(id)
          responses.push "Not a valid ID - use an integer less than the number of quotes (#{@quotes.length})"
        else
          responses.push "Provided ID too small or two large - there are only #{@quotes.length} quotes stored"
      else
        id = Math.floor (Math.random() * @quotes.length)
        responses.push (formatQuote @quotes[id])
        responses.push (formatInfo @quotes[id])
    else if matches[2] is "quote"
      user = matches[1]
      userQuotes = (x for x in @quotes when x.speaker is user)
      if userQuotes.length is 0
        responses.push "No quotes from #{user}"
      else
        id = Math.floor (Math.random() * userQuotes.length)
        responses.push (formatQuote @quotes[id])
        responses.push (formatInfo @quotes[id])
    return responses

  quote: (match, requester) ->
    if match isnt ""
      if match is "that"
        relevant = (x for x in @history[0..5])
      else
        relevant = (x for x in @history[0..10] when x.message.user.name is match)
      responses = ("#{i+1}: #{msg.message.text}" for msg, i in relevant)
      if responses.length is 0
        responses = ["There is nothing to quote"]
      else
        @currentConversations[requester] = relevant
        responses.unshift("Which of the following quotes do you want me to store? Reply by simply saying the number")
    else
      responses = ["Specify a user to quote, or say 'quote that' to quote anyone"]
    return responses

  addQuote: (msg, index) ->
    responder = msg.message.user.name
    if @currentConversations[responder]?
      quotesArr = @currentConversations[responder]
    else
      return false
    index = index - 1
    quote = quotesArr[index]
    if not quote?
      return false
    speaker = quote.message.user.name
    @quotes.push {id: @quotes.length, speaker: speaker, score: 0, text: quote.message.text}
    delete @currentConversations[responder]
    @robot.brain.data.quotes = @quotes
    return true

module.exports = (robot) ->
  quoter = new QuoteServer robot
  pm = (msg, str) ->
    return "/msg #{msg.message.user.name} " + str
  robot.hear /^([1-9])$/, (msg) ->
    if (quoter.addQuote msg, msg.match[1])
      msg.send (pm msg, "Added quote")
  robot.hear //, (msg) ->
    quoter.addToHistory msg
  robot.respond /convos/i, (msg) ->
    quoter.history.pop()
    msg.send (pm msg, s) for s, c of quoter.currentConversations
  robot.respond /history/i, (msg) ->
    quoter.history.pop()
    msg.send (pm msg, quote.message.text) for quote in quoter.history
  robot.respond /quote\b(.*)$/i, (msg) ->
    quoter.history.pop()
    (msg.send (pm msg, s)) for s in (quoter.quote msg.match[1].trim(), msg.message.user.name)
  robot.respond /quotes$/i, (msg) ->
    (msg.send (pm msg, s.text)) for s in (quoter.quotes)
    quoter.history.pop()
  robot.respond /quotes info/i, (msg) ->
    quoter.history.pop()
    quoter.info msg
  robot.respond /tell\s*\b([\w|\-]*)\b\s*([\w|\-]*)/i, (msg) ->
    quoter.history.pop()
    (msg.send s) for s in (quoter.tell msg)
