# Messing around with the Yelp API.
#
# where should we eat <food>

Array::shuffle = -> @sort -> 0.5 - Math.random()

module.exports = (robot) ->
  robot.respond /where should we eat (.*)/i, (msg) ->
    query = msg.match[1]
    msg.http("http://api.yelp.com/business_review_search").query
      ywsid: "UplS3bluyDkpeUwyMm5zlQ"
      location: 10003
      term: query
    .get() (err, res, body) ->
      reviews = JSON.parse(body).businesses
      good_reviews = []
      reviews.map (review) ->
         good_reviews.push(review) if review.avg_rating >= 4
      
      if good_reviews.length > 0
        good_reviews = good_reviews.shuffle()
        msg.send "YOU SHOULD FUCKING EAT: " + good_reviews[0].name + " (" + good_reviews[0].url + ")"
      else
        msg.send "FUCK YOU, NO DINNER TONIGHT"

