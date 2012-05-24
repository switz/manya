# Messing around with the Yelp API.
#
# where should we eat <food>

Array::shuffle = -> @sort -> 0.5 - Math.random()

module.exports = (robot) ->
  robot.respond /where should we eat (.*)/i, (msg) ->
    query = msg.match[1]
    msg.http("http://api.yelp.com/business_review_search")
      .query({
        ywsid: 'UplS3bluyDkpeUwyMm5zlQ',
        location: 10003,
        term: query
      })
      .get() (err, res, body) ->
        reviews = JSON.parse(body)
        reviews = reviews.map (review) -> if (review.avg_rating > 4) return review
		reviews = reviews.shuffle()
        msg.send "You should go to " + reviews[0].name + ", check it out: " + reviews[0].url

